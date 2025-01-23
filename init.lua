local vim = vim
local uname = vim.loop.os_uname()

-- General stuff
vim.cmd.syntax('enable')

vim.cmd('nnoremap <space> :')
vim.cmd('nnoremap <F4> :e %:h<CR>')

local is_sidebar_visible = false;

vim.keymap.set(
    'n',
    '<space><space>',
    function ()
        if not is_sidebar_visible then
            vim.api.nvim_command('NERDTreeFocus')
            is_sidebar_visible = true
        else
            vim.api.nvim_command('NERDTreeClose')
            is_sidebar_visible = false
        end
    end
)

vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.rnu = true
vim.opt.updatetime = 250

vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_altv = 1
vim.g.netrw_keepdir = 1

vim.cmd('filetype plugin indent on')

vim.grepprg = "rg --vimgrep --no-heading --smart-case"

-- Some toggles
vim.cmd('nnoremap - :set rnu!<CR>')
vim.cmd('nnoremap = :set wrap!<CR>')

-- Window navigation
require('navigation').setup()

-- TODO: add oldfiles navigation
-- can you do it with telescope?

-- Matching parenteses - not sure I like it
-- don't duplicate ' since it's annoying when writing english
-- vim.cmd([[
--     inoremap ( ()<Left>
--     inoremap { {}<Left>
--     inoremap [ []<Left>
--     inoremap " ""<Left>
-- ]])

-- TODO: org mode is a bloat, but it's a nice idea!
-- I could write my own plugin that does the same, but using markdown
-- Could I integrate browsing notes with telescope?

-- PLUGIN CONFIG SECTION
-- TODO: can I lock all plugin versions? or better yet - do it by default?
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })

-- General purpose stuff
-- TODO: I don't need plugin themes, create one of my own
Plug('rebelot/kanagawa.nvim')
Plug('preservim/nerdtree')

-- LSP stuff
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('neovim/nvim-lspconfig')

--  ms-jpq
--  This is autocompletion (coq)
--  TODO: coq is good but may be more than I actually need
Plug('ms-jpq/coq_nvim', { ['branch'] = 'coq' })
Plug('ms-jpq/coq.artifacts', { ['branch'] = 'artifacts' })

-- Python
Plug('michaeljsmith/vim-indent-object')

-- Miscellanous
Plug('lewis6991/gitsigns.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('lukas-reineke/indent-blankline.nvim')
-- TODO: might not need this one
Plug('ryanoasis/vim-devicons')

-- Mine
-- Plug("~/src/refactor.nvim/")

vim.call('plug#end')

-- Plugin config
vim.cmd('colorscheme kanagawa')

require("telescope").setup()

vim.g.coq_settings = { ['auto_start'] = 'shut-up' }
local coq = require'coq'

-- LSP
local lsp = require'lspconfig'

require'mason'.setup()
require'mason-lspconfig'.setup({
    ensure_installed = {
        "jedi_language_server",
        "ruff_lsp",
        "tsserver",
        "tailwindcss",
        "lua_ls",
        "rust_analyzer"
    }
})

vim.cmd([[
    autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

-- Lua
lsp.lua_ls.setup(coq.lsp_ensure_capabilities())

-- Python
lsp.jedi_language_server.setup(coq.lsp_ensure_capabilities())
lsp.ruff_lsp.setup(coq.lsp_ensure_capabilities())

vim.cmd([[
    autocmd FileType python set shiftwidth=4 tabstop=4 softtabstop=4 expandtab autoindent fileformat=unix
]])
-- JS
vim.cmd([[
    autocmd BufRead,BufNewFile *.json set filetype=json
    autocmd FileType json setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType javascriptreact setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType typescript setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType typescriptreact setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd FileType css setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
    autocmd BufWritePost *.{js,jsx,ts,tsx} silent !npx prettier <afile> --write
]])

lsp.tsserver.setup(coq.lsp_ensure_capabilities())
lsp.tailwindcss.setup(coq.lsp_ensure_capabilities())

-- Rust
lsp.rust_analyzer.setup(coq.lsp_ensure_capabilities())

-- Misc
require('gitsigns').setup()
require('lualine').setup()

local ibl = require('ibl')
ibl.setup()
ibl.overwrite{
    exclude = { filetypes = { 'python' } }
}

local telescope = require('telescope')
telescope.setup{
    defaults = {
        file_ignore_patterns = {
            'node_modules',
        }
    }
}

local telescope_builtin = require('telescope.builtin')

-- Mappings
vim.keymap.set('n', '<leader>fm', telescope_builtin.marks, {})
vim.keymap.set('n', '<leader>fk', telescope_builtin.keymaps, {})
vim.keymap.set('n', '<leader>fs', telescope_builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>fr', telescope_builtin.lsp_references, {})
vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, {})
vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, {})
vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, {})
vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, {})


-- Mine
-- require('refactor').setup()

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
-- END OF PLUGIN SECTION

-- LaTeX
vim.cmd([[
    autocmd BufWritePost *.tex silent !mkdir -p output && pdflatex --output-directory=output <afile>
    autocmd FileType tex setlocal shiftwidth=2 tabstop=2 softtabstop=0 expandtab
]])

-- BC
-- Calculate line
vim.cmd([[
    nnoremap <leader>cl VyV:!bc -l<esc>0PJa=<space><esc>
]])

