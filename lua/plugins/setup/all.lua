local vim = vim

require 'plugins.setup.lsp'

vim.cmd('colorscheme kanagawa')
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

local mc_setup = function()
    local mc = require('multicursor-nvim')
    mc.setup()

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

local render_markdown = require('render-markdown')
render_markdown.setup{
    file_types = { 'markdown', 'Avante' }
}
vim.treesitter.language.register('markdown', 'Avante')
render_markdown.enable()

require('avante').setup{
    provider = 'claude-haiku'
}
