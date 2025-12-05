local vim = vim
local M = {}
local chan = 0

local TerminalRight = function()
	local buf = vim.api.nvim_create_buf(false, true)
	local _ = vim.api.nvim_open_win(buf, true, { split = "right", style = "minimal" })

	vim.cmd.term()
	vim.cmd.startinsert()

	vim.wo.number = false
	vim.wo.relativenumber = false

	chan = vim.bo.channel
end

M.setup = function()
	vim.api.nvim_create_user_command("TerminalRight", TerminalRight, {})
	vim.keymap.set("n", "<Leader>T", ":TerminalRight<CR>", { noremap = true, silent = true })
	vim.keymap.set("t", "<C-t><C-k>", "<C-\\><C-n>:q<CR>", { noremap = true, silent = true })
end

return M
