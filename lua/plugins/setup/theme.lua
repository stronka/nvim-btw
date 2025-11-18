local vim = vim

require("lspkind").init({})

local gruvbox = require("gruvbox")
gruvbox.setup({
	overrides = {
		SignColumn = {
			bg = gruvbox.palette.dark0,
		},
	},
})

vim.g.colors_name = "gruvbox"
vim.o.background = "dark"
vim.o.termguicolors = true

vim.cmd("colorscheme gruvbox")

local hl = vim.api.nvim_set_hl
hl(0, "DiagnosticSignInfo", { link = "Normal" })

--[[
require("noice").setup {
  views = {
    cmdline_popup = {
      position = {
        row = "95%",
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      }
    }
  },
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    lsp_doc_border = false,
  },
}
--]]
