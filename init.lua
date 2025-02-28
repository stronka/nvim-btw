local vim = vim
local uname = vim.loop.os_uname()

-- General stuff
vim.cmd.syntax('enable')

vim.cmd('nnoremap <space> :')

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

-- PLUGIN CONFIG SECTION
-- TODO: can I lock all plugin versions? or better yet - do it by default?
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })

-- General purpose stuff
Plug('rebelot/kanagawa.nvim')
Plug('preservim/nerdtree')
Plug('easymotion/vim-easymotion')

-- LSP stuff
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('neovim/nvim-lspconfig')

-- Python
Plug('michaeljsmith/vim-indent-object')

-- Version control
Plug('lewis6991/gitsigns.nvim')
Plug('NeogitOrg/neogit')

-- Miscellanous
Plug('nvim-lualine/lualine.nvim')
Plug('lukas-reineke/indent-blankline.nvim')
Plug('ryanoasis/vim-devicons')
Plug('jake-stewart/multicursor.nvim')

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

-- Autocomplete Nvim CMP
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-nvim-lsp')

-- AI! 
-- Avante deps
Plug('stevearc/dressing.nvim')
Plug('MunifTanjim/nui.nvim')
Plug('MeanderingProgrammer/render-markdown.nvim')
Plug('HakonHarnes/img-clip.nvim')
--
Plug('yetone/avante.nvim', { ['branch'] = 'main', ['do'] = 'make' })
-- End of Avante

vim.call('plug#end')

-- Plugin config
vim.cmd('colorscheme kanagawa')

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

local function cmp_setup()
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

        -- For `mini.snippets` users:
        -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        -- insert({ body = args.body }) -- Insert at cursor
        -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
        -- require("cmp.config").set_onetime({ sources = {} })
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
  -- Set configuration for specific filetype.
  --[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
  })
  require("cmp_git").setup() ]]-- 

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- For lsp condig
  return require('cmp_nvim_lsp').default_capabilities()
end

local lsp_capabilities = cmp_setup()

-- LSP
local lsp = require'lspconfig'

require'mason'.setup()
require'mason-lspconfig'.setup({
    ensure_installed = {
        "jedi_language_server",
        "tailwindcss",
        "lua_ls",
        "rust_analyzer"
    }
})

vim.cmd([[
    autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

-- Lua
lsp.lua_ls.setup{
    capabilities = lsp_capabilities
}

-- Python
lsp.jedi_language_server.setup{
    capabilities = lsp_capabilities
}

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

lsp.tailwindcss.setup{
    capabilities = lsp_capabilities
}

-- Rust
lsp.rust_analyzer.setup{
    capabilities = lsp_capabilities
}

-- Version control
require('gitsigns').setup()
local neogit = require('neogit')

local neogit_setup = function ()
    neogit.setup{}
    vim.keymap.set('n', '<F5>', neogit.open)
end

neogit_setup()


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

require('dressing').setup({
    input = {
        winoptions = {
            winhighlight = 'NormalFloat:DiagnosticError'
        }
    }
})
require('render-markdown').setup{}
require('avante').setup{
    provider = 'claude-haiku'
}
--
-- END OF PLUGIN SECTION

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

-- Transparency
vim.api.nvim_set_hl(0, 'Normal', { guibg = nil, ctermbg = nil })
vim.api.nvim_set_hl(0, 'NonText', { guibg = nil, ctermbg = nil })

-- Extra config hook - run at the end
local nvim_extra_config = os.getenv("NVIM_EXTRA_CONFIG")

if nvim_extra_config then
    dofile(nvim_extra_config)
end
