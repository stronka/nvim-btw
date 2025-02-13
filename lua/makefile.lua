local M = {}
local vim = vim

M.setup = function()
    vim.keymap.set(
        'n',
        '<F8>',
        function()
            vim.cmd('make')
        end
    )

    vim.keymap.set(
        'n',
        '<F9>',
        function()
            vim.cmd('make run')
        end
    )
end

return M
