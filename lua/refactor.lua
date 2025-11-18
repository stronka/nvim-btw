local M = {}
local vim = vim

M.setup = function()
	local duplicate_line = function()
		local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
		local line = table.unpack(vim.api.nvim_buf_get_lines(0, row - 1, row, false))
		vim.api.nvim_buf_set_lines(0, row, row, false, { line })
		vim.api.nvim_win_set_cursor(0, { row + 1, col })
	end

	local duplicate_line_backwards = function()
		local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
		local line = table.unpack(vim.api.nvim_buf_get_lines(0, row - 1, row, false))
		vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { line })
		vim.api.nvim_win_set_cursor(0, { row, col })
	end

	local duplicate_selection_lines = function()
		if vim.fn.visualmode() == "" then
			duplicate_line()
			return
		end

		local l1 = vim.fn.getpos("v")[2]
		local _, l2, col, _ = table.unpack(vim.fn.getpos("."))

		local top = math.min(l1, l2)
		local bottom = math.max(l1, l2)
		local ldiff = math.abs(l2 - l1)

		local lines = vim.api.nvim_buf_get_lines(0, top - 1, bottom, false)

		vim.api.nvim_buf_set_lines(0, bottom, bottom, false, lines)
		vim.api.nvim_win_set_cursor(0, { l2 + ldiff + 1, col })
	end

	local duplicate_selection_lines_backwards = function()
		if vim.fn.visualmode() == "" then
			duplicate_line()
			return
		end

		local l1 = vim.fn.getpos("v")[2]
		local _, l2, col, _ = table.unpack(vim.fn.getpos("."))

		local top = math.min(l1, l2)
		local bottom = math.max(l1, l2)

		local lines = vim.api.nvim_buf_get_lines(0, top - 1, bottom, false)

		vim.api.nvim_buf_set_lines(0, top - 1, top - 1, false, lines)
		vim.api.nvim_win_set_cursor(0, { l2, col })
	end

	vim.keymap.set("n", "<C-j>", duplicate_line)

	vim.keymap.set("v", "<C-j>", duplicate_selection_lines)

	vim.keymap.set("n", "<C-k>", duplicate_line_backwards)

	vim.keymap.set("v", "<C-k>", duplicate_selection_lines_backwards)

	vim.keymap.set("n", "<C-y>", function()
		vim.cmd('normal! "*p')
	end)
end

return M
