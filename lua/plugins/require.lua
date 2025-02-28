local vim = vim

local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })

Plug('preservim/nerdtree')

-- LSP stuff
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('neovim/nvim-lspconfig')
--

Plug('lewis6991/gitsigns.nvim')
Plug('NeogitOrg/neogit')

Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-nvim-lsp')

-- Avante deps
Plug('stevearc/dressing.nvim')
Plug('MunifTanjim/nui.nvim')
Plug('MeanderingProgrammer/render-markdown.nvim')
Plug('HakonHarnes/img-clip.nvim')

Plug('yetone/avante.nvim', { ['branch'] = 'main', ['do'] = 'make' })
-- End of Avante

Plug('rebelot/kanagawa.nvim')
Plug('nvim-lualine/lualine.nvim')
Plug('lukas-reineke/indent-blankline.nvim')
Plug('ryanoasis/vim-devicons')
Plug('jake-stewart/multicursor.nvim')
Plug('michaeljsmith/vim-indent-object')
Plug('easymotion/vim-easymotion')

vim.call('plug#end')
