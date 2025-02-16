local M = {}

local vim = vim
local api = vim.api

local file_pattern = "([^%s^%[^%]]*%.[a-zA-Z0-9]+)"
local linenum_pattern = "(%d+)"
local message_pattern =":(.*)"
local error_message_pattern = "^" .. file_pattern .. "[^%d]*" .. linenum_pattern .. ".*" .. message_pattern

local compile_cmd = 'make -k'
local compile_command_history = {}

local result_window = -1
local suggest_win = -1
local input_win = -1
local input_backdrop_win = -1

local buf = -1
local input_buf = -1
local input_backdrop_buf = -1
local suggest_buf = -1

local abort_augroup_id = nil
local abort_input_augroup_id = nil
local compilation_process_handle = nil

-- TODO reformat file
-- TODO pipe and & are not handled!
-- TODO handle terminal output
-- TODO create own higlight group for window backgrounds 

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
        api.nvim_set_option_value('winhighlight', 'NormalFloat:Normal,FloatBorder:NonText,FloatTitle:NonText', {
            scope = 'local',
            win = new_window
        })
        table.insert(result, { window = new_window, buf = new_buf })
    end

    recently_spawned = result
end

local close_windows = function(windows)
    for _, w in ipairs(windows) do
        if w ~= -1 and api.nvim_win_is_valid(w) then
            local b = api.nvim_win_get_buf(w)

            api.nvim_win_close(w, true)

            if b ~= -1 and api.nvim_buf_is_valid(b) then
                api.nvim_buf_delete(b, { force = true })
            end
        end
    end
end

local close_all_windows = function()
    close_windows{ result_window, input_win, suggest_win, input_backdrop_win }

    result_window = -1
    suggest_win = -1
    input_win = -1
    input_backdrop_win = -1

    buf = -1
    input_buf = -1
    suggest_buf = -1
    input_backdrop_buf = -1
end

local abort = function()
    close_all_windows()

    if not abort_augroup_id == nil then
        api.nvim_del_augroup_by_id(abort_augroup_id)
        abort_augroup_id = nil
    end
end

local window_do = function(win, func)
    if win ~= -1 and api.nvim_win_is_valid(win) then
        func()
    end
end


local buffer_do = function(bufid, func)
    if bufid ~= -1 and api.nvim_buf_is_valid(bufid) then
        func()
    end
end

local run_compilation = function()
    vim.cmd('cclose')

    local function save_all_buffers()
        for _, unsaved_buffer in ipairs(api.nvim_list_bufs()) do
            if api.nvim_get_option_value('modified', { buf = unsaved_buffer }) then
                if api.nvim_get_option_value('modifiable', { buf = unsaved_buffer }) then
                    vim.cmd('w')
                end
            end
        end
    end

    save_all_buffers()
    close_all_windows()

    spawn_windows{
        -- result_window
        {
            enter = false,
            opts = {
                split = 'right',
                style = 'minimal',
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

        buffer_do(buf, function()
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                '[Compilation started at: ' ..  os.date() .. ']',
                '',
            })
        end)

        local timestamp = os.clock()

        compilation_process_handle, _ = vim.uv.spawn(cmd, {
            args = args,
            stdio = { nil, stdout, stderr }
        }, function(code, _)
            vim.schedule(function()
                buffer_do(buf, function()
                    local time_elapsed = os.clock() - timestamp
                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
                        '',
                        '[Compilation process finished with ' .. code .. ']',
                        '[CPU time elapsed: ' .. string.format('%.6f', time_elapsed) .. ' s]',
                    })
                    vim.api.nvim_buf_set_option(buf, 'readonly', true)

                    local matches = {}
                    local buffer_content = api.nvim_buf_get_lines(buf, 0, -1, false)

                    for _, line_content in ipairs(buffer_content) do
                        local filename, line_number, message = line_content:match(error_message_pattern)

                        if filename and line_number and message then
                            table.insert(matches, {
                                filename = filename,
                                lnum = tonumber(line_number),
                                col = 0,
                                text = message,
                                type = "E"
                            })

                            -- debug:
                            -- vim.api.nvim_buf_set_lines(buf, -1, -1, false, {'[Match:  ' .. filename .. ':' .. line_number ..']'})
                        end
                    end

                    if #matches > 0 then
                        vim.fn.setqflist(matches, "r")
                        vim.cmd('copen')
                    end
                end)
            end)

            stdout:close()
            stderr:close()

            if compilation_process_handle ~= nil then
                compilation_process_handle:close()
                compilation_process_handle = nil
            end
        end)

        vim.uv.read_start(stdout, vim.schedule_wrap(function(_, data)
            update_buffer(data)
        end))

        vim.uv.read_start(stderr, vim.schedule_wrap(function(_, data)
            update_buffer(data)
        end))
    end

    buffer_do(buf, function()
        abort_augroup_id = api.nvim_create_autocmd('TabLeave', { callback = abort })
    end)

    if compile_cmd == nil or #compile_cmd == 0 then
        update_buffer('No compilation command specified. Aborting')
        return
    end

    if compilation_process_handle ~= nil then
        update_buffer('Previous compilation process has not been finished. Aborting.')
        return
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

    spawn_windows{
        -- input_backdrop_window
        {
            enter = false,
            opts = {
                relative = 'editor',
                width = width,
                height = height,
                row = row,
                col = col,
                style = 'minimal',
                border = 'rounded',
                title = ' Compile ',
                title_pos = 'center'
            },
            buf_opts = {
            },
        },
        -- input_window
        {
            enter = true,
            opts = {
                relative = 'editor',
                width = width - 3,
                height = height,
                row = row + 1,
                col = col + 3,
                style = 'minimal',
                zindex = 200,
            },
            buf_opts = {
            },
        },
    }

    input_backdrop_win  = recently_spawned[1].window
    input_win, input_buf = recently_spawned[2].window, recently_spawned[2].buf

    local ensure_suggestion_window = function()
        if #filtered_choices > 0 then
            if suggest_win ~= -1 and api.nvim_win_is_valid(suggest_win) then
                return
            end

            spawn_windows{
                {
                    enter = false,
                    opts = {
                        relative = 'editor',
                        width = width,
                        height = #filtered_choices,
                        row = row + 3,
                        col = col,
                        style = 'minimal',
                        border = 'rounded',
                        title = ' Recent  ',
                        title_pos = 'center',
                    },
                    buf_opts = {
                    },
                }
            }

            suggest_win, suggest_buf = recently_spawned[1].window, recently_spawned[1].buf
        elseif #filtered_choices == 0 then
            close_windows{ suggest_win }
            suggest_win = -1
            suggest_buf = -1
        end
    end

    local set_selected_suggestion = function ()
        ensure_suggestion_window()
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
        ensure_suggestion_window()
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

        local input_line_content = vim.api.nvim_get_current_line()
        local input = input_line_content:gsub("%s*$", "")

        filtered_choices = {}

        if input ~= nil and #input > 0 then
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

        ensure_suggestion_window()
        window_do(suggest_win, function()
            vim.api.nvim_win_set_height(suggest_win, #filtered_choices)
            set_selected_suggestion()
        end)
    end

    local on_compile = function()
        if not abort_input_augroup_id == nil then
            api.nvim_del_augroup_by_id(abort_input_augroup_id)
            abort_input_augroup_id = nil
        end

        vim.cmd("stopinsert")
        compile_cmd = vim.api.nvim_get_current_line():gsub("%s*$", "")

        if not (compile_cmd == nil or #compile_cmd == 0) then
            local seen = false

            for _, value in ipairs(compile_command_history) do
                if value == compile_cmd then
                    seen = true
                end
            end

            if not seen then
                table.insert(compile_command_history, compile_cmd)
            end
        end

        run_compilation()
    end

    local on_abort = function()
        close_all_windows()
        vim.cmd('stopinsert')
    end

    buffer_do(input_buf, function()
        vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, { compile_cmd .. ' ' })
        vim.api.nvim_win_set_cursor(input_win, {1, #compile_cmd + 1})
    end)

    window_do(input_win, function()
        vim.api.nvim_set_current_win(input_win)
        vim.cmd('startinsert')
    end)

    set_selected_suggestion()

    buffer_do(input_buf, function()
        api.nvim_buf_set_keymap(input_buf, 'i', '<C-n>', '', { noremap = true, callback = on_choose_next_option })
        api.nvim_buf_set_keymap(input_buf, 'i', '<Down>', '', { noremap = true, callback = on_choose_next_option })

        api.nvim_buf_set_keymap(input_buf, 'i', '<C-p>', '', { noremap = true, callback = on_choose_previous_option })
        api.nvim_buf_set_keymap(input_buf, 'i', '<Up>', '', { noremap = true, callback = on_choose_previous_option })

        api.nvim_buf_set_keymap(input_buf, 'i', '<M-BS>', '', { noremap = true, callback = function() vim.cmd('norm dd') end })
        api.nvim_buf_set_keymap(input_buf, 'i', '<Tab>', '', { noremap = true, callback = send_selection_to_input })
        api.nvim_buf_set_keymap(input_buf, 'i', '<CR>', '', { noremap = true, callback = on_compile })
        api.nvim_buf_set_keymap(input_buf, 'i', '<ESC>', '', { noremap = true, callback = on_abort })

        api.nvim_create_autocmd('TextChangedI', { buffer = input_buf, callback = on_text_change })
        abort_input_augroup_id = api.nvim_create_autocmd('BufLeave', { buffer = input_buf, callback = on_abort })
    end)
end

M.setup = function()
    vim.keymap.set('n', '<F7>', compile)
    vim.keymap.set('n', '<C-F7>', run_compilation)
    vim.keymap.set('n', '<M-F7>', abort)
end

return M


