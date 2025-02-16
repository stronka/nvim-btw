local M = {}
local vim = vim

M.setup = function()
    local duplicate_line = function ()
        local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
        local line = table.unpack(vim.api.nvim_buf_get_lines(0, row-1, row, false))
        vim.api.nvim_buf_set_lines(0, row, row, false, { line })
        vim.api.nvim_win_set_cursor(0, {row+1, col})
    end

    local duplicate_line_backwards = function ()
        local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
        local line = table.unpack(vim.api.nvim_buf_get_lines(0, row-1, row, false))
        vim.api.nvim_buf_set_lines(0, row-1, row-1, false, { line })
        vim.api.nvim_win_set_cursor(0, {row, col})
    end

    vim.keymap.set(
        'n',
        '<C-j>',
        duplicate_line
    )

    vim.keymap.set(
        'n',
        '<C-k>',
        duplicate_line_backwards
    )

    vim.keymap.set(
        'n',
        '<C-y>',
        function()
            vim.cmd('normal! "*p')
        end
    )
end


return M
