local M = {}

local vim = vim
local api = vim.api

local compile_cmd = 'make -k'
local compile_command_history = {}

local result_window = -1
local suggest_win = -1
local input_win = -1
local title_win = -1

local buf = -1
local input_buf = -1
local title_buf = -1
local suggest_buf = -1

-- TODO pipe is not handled!
-- TODO handle terminal output
-- TODO parse paths to quickfix

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

local recently_spawned = {}

local spawn_windows = function(window_opts)
    local result = {}

    for _, w in ipairs(window_opts) do
        local new_window = api.nvim_open_win(0, w.enter, w.opts)

        local new_buf = api.nvim_create_buf(false, true)

        for _, b in ipairs(w.buf_opts) do
            api.nvim_buf_set_option(new_buf, b[1], b[2])
        end

        api.nvim_win_set_buf(new_window, new_buf)
        table.insert(result, { window = new_window, buf = new_buf })
    end

    recently_spawned = result
end

local close_windows = function(windows)
    for _, w in ipairs(windows) do
        if api.nvim_win_is_valid(w) then
            local b = api.nvim_win_get_buf(w)

            api.nvim_win_close(w, true)

            if api.nvim_buf_is_valid(b) then
                api.nvim_buf_delete(b, { force = true })
            end
        end
    end
end

local close_all_windows = function()
    close_windows{ result_window, input_win, suggest_win, title_win }

    result_window = -1
    suggest_win = -1
    input_win = -1
    title_win = -1

    buf = -1
    input_buf = -1
    title_buf = -1
    suggest_buf = -1
end

local window_do = function(win, func)
    if api.nvim_win_is_valid(win) then
        func()
    end
end


local buffer_do = function(win, func)
    if api.nvim_buf_is_valid(win) then
        func()
    end
end

local run_compilation = function()
    close_all_windows()
    spawn_windows{
        -- result_window
        {
            enter = false,
            opts = {
                split = 'right',
                win = 0
            },
            buf_opts = {
                {'buftype', 'nofile'},
                {'bufhidden', 'wipe'},
                {'number', false},
                {'relativenumber', false},
            }
        }
    }

    result_window, buf = recently_spawned[1].window, recently_spawned[1].buf

    local update_buffer = function(data)
        buffer_do(buf, function()
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, split_string(data, "[^\r\n]+"))
        end)
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
    close_all_windows()

    local width = 40
    local height = 1
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local selected_index = 1
    local filtered_choices = compile_command_history

    -- state flag when user is switching between options
    local is_switching = false

    local windows_to_spawn = {
        -- input_window
        {
            enter = true,
            opts = {
                relative = 'editor',
                width = width,
                height = height,
                row = row,
                col = col,
                style = "minimal",
                border = "rounded",
            },
            buf_opts = {
            },
        },
        -- title_window
        {
            enter = false,
            opts = {
                relative = "editor",
                width = 10,
                height = 1,
                row = row,
                col = col + width/2 - 4,
                style = "minimal",
                zindex = 200,
            },
            buf_opts = {
            },
        }
    }

    if #filtered_choices > 0 then
        -- suggest_win
        table.insert(windows_to_spawn, {
            enter = false,
            opts = {
                relative = "editor",
                width = width,
                height = #filtered_choices,
                row = row + 2,
                col = col,
                style = "minimal",
                border = "rounded",
            },
            buf_opts = {
            },
        })
    end

    spawn_windows(windows_to_spawn)
    input_win, input_buf = recently_spawned[1].window, recently_spawned[1].buf
    title_win, title_buf = recently_spawned[2].window, recently_spawned[2].buf

    if #filtered_choices > 0 then
        suggest_win, suggest_buf = recently_spawned[3].window, recently_spawned[3].buf
    end

    local set_selected_suggestion = function ()
        local lines = {}

        for i, value in ipairs(filtered_choices) do
            if i == selected_index then
                table.insert(lines, '> ' .. value)
            else
                table.insert(lines, '  ' .. value)
            end
        end

        buffer_do(suggest_buf, function()
            vim.api.nvim_buf_set_lines(suggest_buf, 0, -1, false, lines)
        end)
    end

    local send_selection_to_input = function()
        is_switching = true

        local selected_text = filtered_choices[selected_index]

        buffer_do(input_buf, function()
            vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, { selected_text })
        end)

        window_do(input_win, function()
            vim.api.nvim_win_set_cursor(input_win, {1, #selected_text})
        end)
    end

    local on_choose_next_option = function()
        if #filtered_choices < 1 then
            return
        end

        selected_index = selected_index + 1

        if selected_index > #filtered_choices then
            selected_index = 1
        end

        set_selected_suggestion()
        send_selection_to_input()
    end

    local on_choose_previous_option = function()
        if #filtered_choices < 1 then
            return
        end

        selected_index = selected_index - 1

        if selected_index == 0 then
            selected_index = #filtered_choices
        end

        set_selected_suggestion()
        send_selection_to_input()
    end

    local on_text_change = function()
        if is_switching then
            is_switching = false
            return
        end

        local input = vim.api.nvim_get_current_line():gsub("%s*$", "")

        filtered_choices = {}

        if input ~= nil or input == '' then
            for _, str in ipairs(compile_command_history) do
                local match = false
                local match_index = 1

                for i=1, #input do
                    match = false

                    while not match and match_index < #str + 1 do
                        if not match then
                            if input:sub(i, i) == str:sub(match_index, match_index) then
                                match = true
                            end

                            match_index = match_index + 1
                        end
                    end
                end

                if match then
                    table.insert(filtered_choices, str)
                end
            end
        else
            filtered_choices = compile_command_history
        end

        window_do(suggest_win, function()
            vim.api.nvim_win_set_height(suggest_win, #filtered_choices)
            set_selected_suggestion()
        end)
    end

    local on_compile = function()
        compile_cmd = vim.api.nvim_get_current_line():gsub("%s*$", "")
        vim.cmd("stopinsert")
        local seen = false

        for _, value in ipairs(compile_command_history) do
            if value == compile_cmd then
                seen = true
            end
        end

        if not seen then
            table.insert(compile_command_history, compile_cmd)
        end

        run_compilation()
    end

    local on_abort = function()
        close_all_windows()
        vim.cmd('stopinsert')
    end

    buffer_do(input_buf, function()
        vim.api.nvim_buf_set_keymap(input_buf, "i", "<C-n>", "", { noremap = true, callback = on_choose_next_option })
        vim.api.nvim_buf_set_keymap(input_buf, "i", "<Down>", "", { noremap = true, callback = on_choose_next_option })

        vim.api.nvim_buf_set_keymap(input_buf, "i", "<C-p>", "", { noremap = true, callback = on_choose_previous_option })
        vim.api.nvim_buf_set_keymap(input_buf, "i", "<Up>", "", { noremap = true, callback = on_choose_previous_option })

        vim.api.nvim_create_autocmd("TextChangedI", { buffer = input_buf, callback = on_text_change })

        vim.api.nvim_buf_set_keymap(input_buf, "i", "<CR>", "", { noremap = true, callback = on_compile })
        vim.api.nvim_buf_set_keymap(input_buf, "i", "<ESC>", "", { noremap = true, callback = on_abort })
    end)

    buffer_do(input_buf, function()
        vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, { compile_cmd .. " " })
        vim.api.nvim_win_set_cursor(input_win, {1, #compile_cmd + 1})
    end)

    buffer_do(title_buf, function()
        vim.api.nvim_buf_set_lines(title_buf, 0, -1, false, { " Compile: "})
    end)

    window_do(suggest_win, function()
        set_selected_suggestion()
    end)

    window_do(input_win, function()
        vim.api.nvim_set_current_win(input_win)
        vim.cmd('startinsert')
    end)
end


M.setup = function()
    vim.keymap.set('n', '<F7>', compile)
    vim.keymap.set('n', '<C-F7>', run_compilation)
    vim.keymap.set('n', '<M-F7>', close_all_windows)
end

M.setup()
return M


