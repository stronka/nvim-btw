local vim = vim
local uname = vim.loop.os_uname()

require 'options'
require 'plugins.load'

require 'keymaps'

require('navigation').setup()
require('sidebar').setup()
require('refactor').setup()
require('compile.makefile').setup()
require('terminal').setup()

if (uname.sysname:find 'Windows')
then
    vim.cmd( [[
        let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
        let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
        let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
        let &shellpipe  = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
        set shellquote= shellxquote=
    ]])
end

-- LaTeX
vim.cmd([[
    autocmd BufWritePost *.tex silent !mkdir -p output && pdflatex --output-directory=output <afile>
    autocmd FileType tex setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
]])


-- Transparency
vim.api.nvim_set_hl(0, 'Normal', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'NonText', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'LineNr', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'SignColumn', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'StatusLine', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'StatusLineNC', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'FloatBorder', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'FloatTitle', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'FloatFooter', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'NormalFloat', { guibg = nil, ctermbg = nil })

-- Extra config hook - run at the end
local nvim_extra_config = os.getenv("NVIM_EXTRA_CONFIG")

if nvim_extra_config then
    dofile(nvim_extra_config)
end
