local M = {}
local vim = vim

local compile_cmd = 'make'
local result_window = -1
local buf = -1

local split_string = function(str, pattern)
    if rawequal(str, nil) then
        return {}
    end

    local tokens = {}

    for line in str:gmatch(pattern) do
        table.insert(tokens, line)
    end

    if rawequal(next(tokens), nil) then
        return {str}
    end

    return tokens
end

local run_compilation = function()
    local current_window = vim.api.nvim_get_current_win()

    if vim.api.nvim_win_is_valid(result_window) then
        vim.api.nvim_win_close(result_window, true)
    end

    if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
    end


    result_window = vim.api.nvim_open_win(0, false, {
        split = 'right',
        win = 0
    })

    buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'number', false)
    vim.api.nvim_buf_set_option(buf, 'relativenumber', false)
    vim.api.nvim_win_set_buf(result_window, buf)

    vim.api.nvim_set_current_win(current_window)

    local update_buffer = function(data)
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, split_string(data, "[^\r\n]+"))
    end

    local run = function()
        local stdout = vim.uv.new_pipe()
        local stderr = vim.uv.new_pipe()

        local cmd_table = split_string(compile_cmd, "[^ ]+")
        local cmd, args = cmd_table[1], { table.unpack(cmd_table, 2) }

        local handle
        handle, _ = vim.uv.spawn(cmd, {
            args = args,
            stdio = { nil, stdout, stderr }
        }, function(code, _)
            vim.schedule(function()
                vim.api.nvim_buf_set_lines(buf, -1, -1, false, {'[Compilation process finished with ' .. code .. ']'})
                vim.api.nvim_buf_set_option(buf, 'readonly', true)
            end)

            stdout:close()
            stderr:close()
            handle:close()
        end)

        vim.uv.read_start(stdout, vim.schedule_wrap(function(_, data)
            update_buffer(data)
        end))

        vim.uv.read_start(stderr, vim.schedule_wrap(function(_, data)
            update_buffer(data)
        end))
    end

    run()

end


local compile = function()
    vim.ui.input({ prompt = 'Compile: ', default = compile_cmd }, function(input)
        compile_cmd = input
        run_compilation()
    end)
end


M.setup = function()
    vim.keymap.set(
        'n',
        '<F7>',
        compile
    )

    vim.keymap.set(
        'n',
        '<C-F7>',
        run_compilation
    )

    vim.keymap.set(
        'n',
        '<M-F7>',
        function()
            if vim.api.nvim_win_is_valid(result_window) then
                vim.api.nvim_win_close(result_window, true)
                result_window = -1
            end
        end
    )
end

return M


