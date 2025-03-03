local vim = vim

vim.cmd('nnoremap - :set rnu!<CR>')
vim.cmd('nnoremap _ :set wrap!<CR>')

vim.keymap.set('n', '<leader>qe', function()
    -- for quickfix edits
    vim.opt_local.errorformat = "%f|%l col %c|%m"
end)

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
end

telescope_setup()

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

local neogit_setup = function ()
    local neogit = require('neogit')
    vim.keymap.set('n', '<F5>', neogit.open)
end

neogit_setup()

local mc_setup = function()
    local mc = require('multicursor-nvim')

    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set({"n", "x"}, "<up>", function() mc.lineAddCursor(-1) end)
    set({"n", "x"}, "<down>", function() mc.lineAddCursor(1) end)
    set({"n", "x"}, "<leader><up>", function() mc.lineSkipCursor(-1) end)
    set({"n", "x"}, "<leader><down>", function() mc.lineSkipCursor(1) end)

    -- Add or skip adding a new cursor by matching word/selection
    set({"n", "x"}, "<M-n>", function() mc.matchAddCursor(0) end)
    set({"n", "x"}, "<M-s>", function() mc.matchSkipCursor(1) end)
    set({"n", "x"}, "<M-N>", function() mc.matchAddCursor(-1) end)
    set({"n", "x"}, "<M-S>", function() mc.matchSkipCursor(-1) end)

    -- In normal/visual mode, press `mwap` will create a cursor in every match of
    -- the word captured by `iw` (or visually selected range) inside the bigger
    -- range specified by `ap`. Useful to replace a word inside a function, e.g. mwif.
    set({"n", "x"}, "mw", function() mc.operator({ motion = "iw", visual = true })
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
end

mc_setup()
