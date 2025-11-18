local vim = vim

require("gitsigns").setup()
require("neogit").setup {}

local mc_setup = function()
	local mc = require("multicursor-nvim")
	mc.setup()

	local hl = vim.api.nvim_set_hl
	hl(0, "MultiCursorCursor", { link = "Cursor" })
	hl(0, "MultiCursorVisual", { link = "Visual" })
	hl(0, "MultiCursorSign", { link = "SignColumn" })
	hl(0, "MultiCursorMatchPreview", { link = "Search" })
	hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
	hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
	hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
end

mc_setup()

require("orgmode").setup {
	org_agenda_files = "~/Documents/notes/**/*",
	org_default_notes_file = "~/Documents/notes/refile.org",
}
