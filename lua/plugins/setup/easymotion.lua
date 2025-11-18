local vim = vim

local easymotion_setup = function()
	vim.g.EasyMotion_smartcase = 1
	vim.api.nvim_set_keymap("n", "<Leader><Leader>w", "<Plug>(easymotion-bd-w)", {})
	vim.api.nvim_set_keymap("n", "s", "<Plug>(easymotion-s)", {})
	vim.api.nvim_set_keymap("n", "<Leader>w", "<Plug>(easymotion-w)", {})
	vim.api.nvim_set_keymap("n", "<Leader>b", "<Plug>(easymotion-b)", {})
	vim.api.nvim_set_keymap("n", "<Leader>f", "<Plug>(easymotion-f)", {})
	vim.api.nvim_set_keymap("n", "<Leader>t", "<Plug>(easymotion-t)", {})
	vim.api.nvim_set_keymap("n", "<Leader>l", "<Plug>(easymotion-j)", {})
	vim.api.nvim_set_keymap("n", "<Leader>h", "<Plug>(easymotion-k)", {})
end

easymotion_setup()
