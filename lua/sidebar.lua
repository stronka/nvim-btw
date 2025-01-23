local M = {}
local vim = vim

M.setup = function ()
    local is_sidebar_focused = false
    local sidebar_augroup = vim.api.nvim_create_augroup("SidebarGroup", { clear = true })
    local sidebar_aucmd = nil;

    local on_focus_leave = function()
        is_sidebar_focused=false

        if sidebar_aucmd then
            vim.api.nvim_del_autocmd(sidebar_aucmd)
            sidebar_aucmd = nil
        end
    end

    local on_focus_enter = function()
        is_sidebar_focused = true

        sidebar_aucmd = vim.api.nvim_create_autocmd({"BufLeave"}, {
            callback = on_focus_leave,
            group = sidebar_augroup
        })
    end

    vim.keymap.set(
        'n',
        '<space><space>',
        function ()
            if not is_sidebar_focused then
                vim.api.nvim_command('NERDTreeFocus')
                on_focus_enter()
            else
                vim.api.nvim_command('NERDTreeClose')
                on_focus_leave()
            end
        end
    )

    vim.keymap.set(
        'n',
        '<leader>tt',
        function()
            vim.api.nvim_command('NERDTreeFind')
            on_focus_enter()
        end
    )

    vim.keymap.set(
        'n',
        '<leader>tr',
        function()
            vim.api.nvim_command('NERDTreeCWD')
        end
    )
end

return M
