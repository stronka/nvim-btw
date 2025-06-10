local vim = vim
local telescope = require('telescope')
telescope.setup{
    defaults = {
        file_ignore_patterns = {
            'node_modules',
        }
    }
}

local telescope_builtin = require('telescope.builtin')

local function telescope_setup()
    vim.keymap.set('n', '<leader>fm', telescope_builtin.marks, {})
    vim.keymap.set('n', '<leader>fk', telescope_builtin.keymaps, {})
    vim.keymap.set('n', '<leader>fs', telescope_builtin.lsp_document_symbols, {})
    vim.keymap.set('n', '<leader>fr', telescope_builtin.lsp_references, {})
    vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, {})
    vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, {})
    vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, {})
    vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, {})

    vim.keymap.set('n', '<leader>fw', function()
        telescope_builtin.grep_string{
            search=vim.fn.expand('<cword>')
        }
    end, {})
end

telescope_setup()
