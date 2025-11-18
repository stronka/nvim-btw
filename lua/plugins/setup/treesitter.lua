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

-- terraform
vim.treesitter.language.register("terraform", { "terraform", "terraform-vars" })
