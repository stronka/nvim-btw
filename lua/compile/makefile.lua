local M = {}

local vim = vim
local api = vim.api

local history = require("compile.history")

local file_pattern = "([^%s^%[^%]]*%.[a-zA-Z0-9]+)"
local linenum_pattern = "(%d+)"
local message_pattern = ":(.*)"
local error_message_pattern = "^" .. file_pattern .. "[^%d]*" .. linenum_pattern .. ".*" .. message_pattern

local result_window = -1
local suggest_win = -1
local input_win = -1
local input_backdrop_win = -1

local buf = -1

local abort_augroup_id = nil
local compilation_process_handle = nil

local compile_window_breakpoint = 200

local split_string = function(str, pattern)
	if rawequal(str, nil) then
		return {}
	end

	local tokens = {}

	for line in str:gmatch(pattern) do
		table.insert(tokens, line)
	end

	if rawequal(next(tokens), nil) then
		return { str }
	end

	return tokens
end

local recently_spawned = {}

local spawn_windows = function(window_opts)
	local result = {}

	for _, w in ipairs(window_opts) do
		local new_window = api.nvim_open_win(0, w.enter, w.opts)
		local new_buf = api.nvim_create_buf(false, true)

		for opt, val in pairs(w.win_opts) do
			api.nvim_set_option_value(opt, val, { win = new_window })
		end

		for _, b in ipairs(w.buf_opts) do
			api.nvim_buf_set_option(new_buf, b[1], b[2])
		end

		api.nvim_win_set_buf(new_window, new_buf)
		api.nvim_set_option_value(
			"winhighlight",
			"NormalFloat:Normal,FloatBorder:DiagnosticSignInfo,FloatTitle:DiagnosticSignInfo",
			{
				scope = "local",
				win = new_window,
			}
		)
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
	close_windows { result_window, input_win, suggest_win, input_backdrop_win }

	result_window = -1
	suggest_win = -1
	input_win = -1
	input_backdrop_win = -1

	buf = -1
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

local run_compilation = function(command, interactive)
	vim.cmd("cclose")

	local function save_all_buffers()
		for _, unsaved_buffer in ipairs(api.nvim_list_bufs()) do
			if not unsaved_buffer then
				goto continue
			elseif not api.nvim_get_option_value("modified", { buf = unsaved_buffer }) then
				goto continue
			elseif api.nvim_get_option_value("buftype", { buf = unsaved_buffer }) ~= "" then
				goto continue
			end

			vim.cmd("w")
			::continue::
		end
	end

	save_all_buffers()
	close_all_windows()

	local current_width = vim.api.nvim_win_get_width(0)

	local split_style = "right"

	if current_width < compile_window_breakpoint then
		split_style = "below"
	end

	spawn_windows {
		-- result_window
		{
			enter = false,
			opts = {
				split = split_style,
				style = "minimal",
				win = 0,
			},
			win_opts = {
				previewwindow = true,
			},
			buf_opts = {
				{ "buftype", "nofile" },
				{ "bufhidden", "wipe" },
				{ "number", false },
				{ "relativenumber", false },
			},
		},
	}

	result_window, buf = recently_spawned[1].window, recently_spawned[1].buf

	local update_buffer = function(data)
		if data == nil then
			return
		end

		data = data
			:gsub("\x1b%[%d+;%d+;%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+;%d+m", "")
			:gsub("\x1b%[%d+;%d+m", "")
			:gsub("\x1b%[%d+m", "")

		buffer_do(buf, function()
			local lines_to_print = {}
			local sanitized_line

			for _, line in ipairs(split_string(data, "[^\r\n]+")) do
				sanitized_line = line:gsub("[\r\n]+", "")
				table.insert(lines_to_print, sanitized_line)
			end

			api.nvim_buf_set_lines(buf, -1, -1, false, lines_to_print)

			api.nvim_win_set_cursor(result_window, { api.nvim_buf_line_count(buf), 0 })
		end)
	end

	local run = function()
		local stdout = vim.uv.new_pipe()
		local stderr = vim.uv.new_pipe()

		buffer_do(buf, function()
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
				"[Compilation started at: " .. os.date() .. "]",
				"",
			})
		end)

		local timestamp = os.clock()

		compilation_process_handle, _ = vim.uv.spawn("zsh", {
			args = { interactive and "-ic" or "-c", command },
			stdio = { nil, stdout, stderr },
		}, function(code, _)
			vim.schedule(function()
				buffer_do(buf, function()
					local time_elapsed = os.clock() - timestamp
					vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
						"",
						"[Compilation process finished with " .. code .. "]",
						"[CPU time elapsed: " .. string.format("%.6f", time_elapsed) .. " s]",
					})
					vim.api.nvim_buf_set_option(buf, "readonly", true)

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
								type = "E",
							})

							-- debug:
							-- vim.api.nvim_buf_set_lines(buf, -1, -1, false, {'[Match:  ' .. filename .. ':' .. line_number ..']'})
						end
					end

					if #matches > 0 then
						vim.fn.setqflist(matches, "r")
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

		vim.uv.read_start(
			stdout,
			vim.schedule_wrap(function(_, data)
				update_buffer(data)
			end)
		)

		vim.uv.read_start(
			stderr,
			vim.schedule_wrap(function(_, data)
				update_buffer(data)
			end)
		)
	end

	if command == nil or #command == 0 then
		update_buffer("No compilation command specified. Aborting")
		return
	end

	if compilation_process_handle ~= nil then
		update_buffer("Previous compilation process has not been finished. Aborting.")
		return
	end

	run()
end

api.nvim_create_user_command("Compile", function(opts)
	run_compilation(opts.args, opts.bang)
	history.save_command(opts.args)
end, {
	nargs = "+",
	bang = true,
	complete = history.complete,
})

api.nvim_create_user_command("Recompile", function(args)
	run_compilation(history.last_command, false)
end, {
	nargs = 0,
})

M.setup = function()
	vim.keymap.set("n", "<space><space>", function()
		api.nvim_feedkeys(api.nvim_replace_termcodes(":Compile ", true, false, true), "n", false)
	end)

	vim.keymap.set("n", "<leader>rr", function()
		api.nvim_command("Recompile")
	end)

	vim.keymap.set("n", "<leader>ra", abort)
end

return M
