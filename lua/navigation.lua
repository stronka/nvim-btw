local vim = vim
local M = {}

M.setup = function()
	vim.cmd([[
        nnoremap <C-w><C-o> :only<CR>
        nnoremap <C-w><C-n> <C-w>j
        nnoremap <C-w><C-p> <C-w>k
        nnoremap <C-w><C-s> :sp<CR>
        nnoremap <C-w><C-v> :vsp<CR>
        nnoremap <C-w><C-q> <C-w>q
        nnoremap <C-w><C-[> <C-w>h
        nnoremap <C-w><C-]> <C-w>l
    ]])

	-- Tab navigation
	vim.cmd([[
        nnoremap <C-t><C-t> :tabnew<CR>
        nnoremap <C-t><C-e> :tabe<space>
        nnoremap <C-t><C-q> :tabc<CR>
        nnoremap <C-t><C-p> :tabp<CR>
        nnoremap <C-t><C-n> :tabn<CR>
    ]])

	-- Buffer navigation
	vim.cmd([[
        nnoremap <C-b><C-b> :ls<CR>
        nnoremap <C-b><C-j> :ls<CR>:b<space>
        nnoremap <C-b><C-q> :ls<CR>:bdelete<space>
        nnoremap <C-b><C-p> :bp<CR>
        nnoremap <C-b><C-n> :bn<CR>
    ]])

	-- Quickfix list navigation
	-- M-F7 obsolete with the refactor.nvim plugin, search to replace
	vim.cmd([[
        nnoremap <M-F7> yiw:grep<space><C-r>"<space> 
        nnoremap <C-l><C-l> :copen<CR>
        nnoremap <C-l><C-q> :cclose<CR>
        nnoremap <C-l><C-p> :cprevious<CR>
        nnoremap <C-l><C-n> :cnext<CR>
    ]])

	-- Tmode navigation
	vim.cmd([[
        tnoremap <C-t><C-t> <C-\><C-n>
    ]])

	-- Scroll the preview window
	vim.keymap.set("n", "<M-u>", function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>P", true, false, true), "n", false)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-u>", true, false, true), "n", false)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>p", true, false, true), "n", false)
	end, {
		noremap = true,
	})

	vim.keymap.set("n", "<M-d>", function()
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>P", true, false, true), "n", false)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-d>", true, false, true), "n", false)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>p", true, false, true), "n", false)
	end, {
		noremap = true,
	})
end

return M
