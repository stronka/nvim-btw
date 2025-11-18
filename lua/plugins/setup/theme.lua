local vim = vim

require("lspkind").init {}

local gruvbox = require("gruvbox")
gruvbox.setup {
	overrides = {
		SignColumn = {
			bg = gruvbox.palette.dark0,
		},
	},
}

vim.g.colors_name = "gruvbox"
vim.o.background = "dark"
vim.o.termguicolors = true

vim.cmd("colorscheme gruvbox")

local hl = vim.api.nvim_set_hl
hl(0, "DiagnosticSignInfo", { link = "Normal" })

-- indent line
local ibl = require("ibl")
ibl.setup()
ibl.overwrite {
	exclude = { filetypes = { "python" } },
}
