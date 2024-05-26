local vim = vim

-- General stuff
vim.cmd.syntax('enable')

vim.cmd('inoremap jj <ESC>')
vim.cmd('inoremap kk <ESC>')

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.g.netrw_winsize = 25
vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0

vim.opt.rnu=true
vim.cmd('nnoremap - :set rnu!<CR>')
vim.cmd('nnoremap + :set wrap!<CR>')
vim.cmd('nnoremap // :set hls!<CR>')

vim.cmd('filetype plugin indent on')

local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })

-- Colorschemes
Plug('navarasu/onedark.nvim')
Plug('catppuccin/nvim', { ['as'] = 'catppuccin'})
Plug('rebelot/kanagawa.nvim')

-- LSP stuff
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('neovim/nvim-lspconfig')

--  ms-jpq
Plug('ms-jpq/coq_nvim', { ['branch'] = 'coq' })
Plug('ms-jpq/coq.artifacts', { ['branch'] = 'artifacts' })
Plug('ms-jpq/chadtree', { ['branch'] = 'chad', ['do'] = 'python 3 -m chadtree deps' })

-- Python
Plug('michaeljsmith/vim-indent-object')
Plug('averms/black-nvim', { ['do'] = ':UpdateRemotePlugins' })

-- Miscellanous
Plug('lewis6991/gitsigns.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('lukas-reineke/indent-blankline.nvim')
Plug('ryanoasis/vim-devicons')

vim.call('plug#end')

-- Plugin config
vim.cmd('colorscheme kanagawa')

require("telescope").setup()

vim.g.coq_settings = { ['auto_start'] = 'shut-up' }
local coq = require'coq'

-- LSP
local lsp = require'lspconfig'
local configs = require('lspconfig/configs')

require'mason'.setup()
require'mason-lspconfig'.setup({
    ensure_installed = { 
        "jedi_language_server",
        "ruff_lsp",
        "tsserver",
        "tailwindcss"
    }
})

-- Python
lsp.jedi_language_server.setup(coq.lsp_ensure_capabilities())
lsp.ruff_lsp.setup(coq.lsp_ensure_capabilities())

-- JS
vim.cmd([[
    autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType javascriptreact setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType typescript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType typescriptreact setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
]])

lsp.tsserver.setup(coq.lsp_ensure_capabilities())
lsp.tailwindcss.setup(coq.lsp_ensure_capabilities())

-- Misc
require('gitsigns').setup()
require('lualine').setup()

local ibl = require('ibl')
ibl.setup()
ibl.overwrite{
    exclude = { filetypes = { 'python' } }
}

require('telescope').setup{
    defaults = {
        file_ignore_patterns = {
            'node_modules'
        }
    }
}

-- Mappings
vim.cmd([[
    nnoremap <leader>ff <cmd>Telescope find_files<cr>

    nnoremap <leader>fg <cmd>Telescope live_grep<cr>
    nnoremap <leader>fb <cmd>Telescope buffers<cr>
    nnoremap <leader>fh <cmd>Telescope help_tags<cr>

    nnoremap <leader>fr <cmd>Telescope lsp_references<cr>
    nnoremap <leader>fs <cmd>Telescope lsp_document_symbols<cr>
]])

vim.cmd([[
    nnoremap <leader>v <cmd>CHADopen<cr>
]])
