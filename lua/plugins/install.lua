local vim = vim

local Plug = vim.fn["plug#"]

vim.call("plug#begin")
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim", { ["tag"] = "0.1.6" })

Plug("preservim/nerdtree")
Plug("hedyhli/outline.nvim", { ["tag"] = "v1.1.0" })
-- Plug('stevearc/aerial.nvim')

-- LSP stuff
Plug("williamboman/mason.nvim")
Plug("williamboman/mason-lspconfig.nvim")
Plug("neovim/nvim-lspconfig")

Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate", ["version"] = "v0.10.0" })
Plug("hrsh7th/nvim-cmp")
Plug("hrsh7th/cmp-cmdline")
Plug("hrsh7th/cmp-path")
Plug("hrsh7th/cmp-buffer")
Plug("hrsh7th/cmp-nvim-lsp")

-- Snippets
Plug("rafamadriz/friendly-snippets")
Plug(
	"L3MON4D3/LuaSnip",
	{ ["tag"] = "v2.4.1", ["do"] = "make install_jsregexp", ["dependencies"] = { "rafamadriz/friendly-snippets" } }
)
Plug("saadparwaiz1/cmp_luasnip")

-- Git
Plug("lewis6991/gitsigns.nvim")
Plug("NeogitOrg/neogit")

-- Avante deps
Plug("stevearc/dressing.nvim")
Plug("MunifTanjim/nui.nvim")
Plug("MeanderingProgrammer/render-markdown.nvim")
Plug("HakonHarnes/img-clip.nvim")

Plug("yetone/avante.nvim", { ["branch"] = "main", ["do"] = "make", ["version"] = "v0.0.23" })
-- End of Avante

Plug("nomnivore/ollama.nvim")

-- Debugging
Plug("mfussenegger/nvim-dap", { ["tag"] = "0.10.0" })
Plug("mfussenegger/nvim-dap-python")
Plug("nvim-neotest/nvim-nio", { ["tag"] = "v1.10.1" })
Plug("rcarriga/nvim-dap-ui", { ["tag"] = "v4.0.0" })
Plug("theHamsta/nvim-dap-virtual-text")
--

-- Theme stuff
Plug("rebelot/kanagawa.nvim")
Plug("ellisonleao/gruvbox.nvim", { ["tag"] = "2.0.0" })
Plug("catppuccin/nvim", { ["tag"] = "v1.11.0", ["as"] = "catppuccin" })
Plug("luochen1990/rainbow")
Plug("nvim-lualine/lualine.nvim")
Plug("lukas-reineke/indent-blankline.nvim")
Plug("ryanoasis/vim-devicons")
Plug("onsails/lspkind.nvim")

-- Misc
-- Plug('folke/noice.nvim', { ['tag'] = 'v4.10.0' })
Plug("jake-stewart/multicursor.nvim")
Plug("michaeljsmith/vim-indent-object")
Plug("easymotion/vim-easymotion")
Plug("nvim-orgmode/orgmode")

vim.call("plug#end")
