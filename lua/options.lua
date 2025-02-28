local vim = vim

vim.cmd.syntax('enable')
vim.cmd('nnoremap <space> :')
vim.cmd('filetype plugin indent on')

vim.g.netrw_altv = 1
vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 1
vim.g.netrw_liststyle = 3

vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.rnu = true
vim.opt.shiftwidth = 4
vim.opt.splitbelow = true
vim.opt.tabstop = 4
vim.opt.updatetime = 250
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
