local vim = vim
local M = {}
local chan = 0
local buf = -1

local TerminalRight = function()
    if buf == -1 or vim.api.nvim_buf_is_valid(buf) then
        buf = vim.api.nvim_create_buf(false, true)
    end

    local _ = vim.api.nvim_open_win(buf, true, { split = 'right', style = 'minimal' })

    vim.cmd.term()
    vim.cmd.startinsert()

    vim.wo.number = false
    vim.wo.relativenumber = false

    chan = vim.bo.channel
end

M.setup = function()
    vim.api.nvim_create_user_command('TerminalRight', TerminalRight, {})
    vim.keymap.set('n', '<Leader>tr', ':TerminalRight<CR>', { noremap = true, silent = true })
    vim.keymap.set('t', '<C-t><C-k>', '<C-\\><C-n>:q<CR>', { noremap = true, silent = true })
end

return M
