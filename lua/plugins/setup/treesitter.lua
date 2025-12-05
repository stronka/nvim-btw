local vim = vim

require("nvim-treesitter.configs").setup {
	ensure_installed = {
		"c",
		"cpp",
		"lua",
		"python",
		"vim",
		"vimdoc",
		"markdown",
		"markdown_inline",
		"javascript",
		"typescript",
		"html",
	},
	ignore_install = { "org" },
	highlit = {
		enable = true,
	},
}

require("nvim-treesitter.configs").setup {
	textobjects = {
		select = {
			enable = true,
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
				["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
			},
			selection_modes = {
				["@parameter.outer"] = "v", -- charwise
				["@function.outer"] = "V", -- linewise
				["@class.outer"] = "<c-v>", -- blockwise
			},
			include_surrounding_whitespace = false,
		},
	},
}

-- terraform
vim.treesitter.language.register("terraform", { "terraform", "terraform-vars" })
