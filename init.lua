local vim = vim
local uname = vim.loop.os_uname()

-- General stuff
vim.cmd.syntax('enable')

vim.cmd('nnoremap <space> :')
vim.cmd('nnoremap <F4> :e %:h<CR>')

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

vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"

vim.keymap.set('n', '<leader>qe', function()
    -- for quickfix edits
    vim.opt_local.errorformat = "%f|%l col %c|%m"
end)

-- Some toggles
vim.cmd('nnoremap - :set rnu!<CR>')
vim.cmd('nnoremap = :set wrap!<CR>')

-- My stuff
require('navigation').setup()
require('sidebar').setup()
require('refactor').setup()
require('makefile').setup()

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
Plug('easymotion/vim-easymotion')

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

-- Version control
Plug('lewis6991/gitsigns.nvim')
Plug('NeogitOrg/neogit')

-- Miscellanous
Plug('nvim-lualine/lualine.nvim')
Plug('lukas-reineke/indent-blankline.nvim')
-- TODO: might not need this one
Plug('ryanoasis/vim-devicons')

-- Mutliple cursor - TODO examine
Plug('jake-stewart/multicursor.nvim')

vim.call('plug#end')

-- Plugin config
vim.cmd('colorscheme kanagawa')

require("telescope").setup()

vim.g.coq_settings = { ['auto_start'] = 'shut-up' }
local coq = require'coq'

-- Enable case-sensitive search
local easymotion_setup = function ()
    vim.g.EasyMotion_smartcase = 1
    vim.api.nvim_set_keymap('n', '<Leader><Leader>w', '<Plug>(easymotion-bd-w)', {})
    vim.api.nvim_set_keymap('n', 's', '<Plug>(easymotion-s)', {})
    vim.api.nvim_set_keymap('n', '<Leader>w', '<Plug>(easymotion-w)', {})
    vim.api.nvim_set_keymap('n', '<Leader>b', '<Plug>(easymotion-b)', {})
    vim.api.nvim_set_keymap('n', '<Leader>f', '<Plug>(easymotion-f)', {})
    vim.api.nvim_set_keymap('n', '<Leader>t', '<Plug>(easymotion-t)', {})
    vim.api.nvim_set_keymap('n', '<Leader>l', '<Plug>(easymotion-j)', {})
    vim.api.nvim_set_keymap('n', '<Leader>h', '<Plug>(easymotion-k)', {})
end

easymotion_setup()

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

-- Version control
require('gitsigns').setup()
require('neogit').setup{}

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

local mc = require('multicursor-nvim')

local mc_setup = function()
    mc.setup()

    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set({"n", "x"}, "<up>",
        function() mc.lineAddCursor(-1) end)
    set({"n", "x"}, "<down>",
        function() mc.lineAddCursor(1) end)
    set({"n", "x"}, "<leader><up>",
        function() mc.lineSkipCursor(-1) end)
    set({"n", "x"}, "<leader><down>",
        function() mc.lineSkipCursor(1) end)

    -- Add or skip adding a new cursor by matching word/selection
    set({"n", "x"}, "<M-n>",
        function() mc.matchAddCursor(0) end)
    set({"n", "x"}, "<M-s>",
        function() mc.matchSkipCursor(1) end)
    set({"n", "x"}, "<M-N>",
        function() mc.matchAddCursor(-1) end)
    set({"n", "x"}, "<M-S>",
        function() mc.matchSkipCursor(-1) end)

    -- In normal/visual mode, press `mwap` will create a cursor in every match of
    -- the word captured by `iw` (or visually selected range) inside the bigger
    -- range specified by `ap`. Useful to replace a word inside a function, e.g. mwif.
    set({"n", "x"}, "mw", function()
        mc.operator({ motion = "iw", visual = true })
        -- Or you can pass a pattern, press `mwi{` will select every \w,
        -- basically every char in a `{ a, b, c, d }`.
        -- mc.operator({ pattern = [[\<\w]] })
    end)

    -- Press `mWi"ap` will create a cursor in every match of string captured by `i"` inside range `ap`.
    set("n", "mW", mc.operator)

    -- Add all matches in the document
    set({"n", "x"}, "<leader>A", mc.matchAllAddCursors)

    -- You can also add cursors with any motion you prefer:
    -- set("n", "<right>", function()
    --     mc.addCursor("w")
    -- end)
    -- set("n", "<leader><right>", function()
    --     mc.skipCursor("w")
    -- end)

    -- Rotate the main cursor.
    set({"n", "x"}, "<left>", mc.nextCursor)
    set({"n", "x"}, "<right>", mc.prevCursor)

    -- Delete the main cursor.
    set({"n", "x"}, "<M-k>", mc.deleteCursor)

    -- Add and remove cursors with control + left click.
    set("n", "<c-leftmouse>", mc.handleMouse)
    set("n", "<c-leftdrag>", mc.handleMouseDrag)

    -- Easy way to add and remove cursors using the main cursor.
    set({"n", "x"}, "<c-q>", mc.toggleCursor)

    -- Clone every cursor and disable the originals.
    set({"n", "x"}, "<leader><c-q>", mc.duplicateCursors)

    set("n", "<esc>", function()
        if not mc.cursorsEnabled() then
            mc.enableCursors()
        elseif mc.hasCursors() then
            mc.clearCursors()
        else
            -- Default <esc> handler.
        end
    end)

    -- bring back cursors if you accidentally clear them
    set("n", "<leader>gv", mc.restoreCursors)

    -- Align cursor columns.
    set("n", "<leader>a", mc.alignCursors)

    -- Split visual selections by regex.
    set("x", "S", mc.splitCursors)

    -- Append/insert for each line of visual selections.
    set("x", "I", mc.insertVisual)
    set("x", "A", mc.appendVisual)

    -- match new cursors within visual selections by regex.
    set("x", "M", mc.matchCursors)

    -- Rotate visual selection contents.
    set("x", "<leader>t",
        function() mc.transposeCursors(1) end)
    set("x", "<leader>T",
        function() mc.transposeCursors(-1) end)

    -- Jumplist support
    set({"x", "n"}, "<c-i>", mc.jumpForward)
    set({"x", "n"}, "<c-o>", mc.jumpBackward)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { link = "Cursor" })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn"})
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
end

mc_setup()


-- Mine

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

-- Extra config hook - run at the end
local nvim_extra_config = os.getenv("NVIM_EXTRA_CONFIG")

if nvim_extra_config then
    dofile(nvim_extra_config)
end
