local vim = vim

vim.cmd("nnoremap - :set rnu!<CR>")
vim.cmd("nnoremap _ :set wrap!<CR>")

vim.keymap.set("n", "<leader>cp", function()
	vim.cmd("let @+ = expand('%:~:.')")
end)

vim.keymap.set("n", "<leader>qe", function()
	-- for quickfix edits
	vim.opt_local.errorformat = "%f|%l col %c|%m"
end)
