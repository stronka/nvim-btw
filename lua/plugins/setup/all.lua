local vim = vim

require("gitsigns").setup()
require("neogit").setup({})

-- ollama
require("ollama").setup({
	model = "codellama",
	stream = true,
	serve = {
		command = "ollama",
		args = { "serve" },
		stop_command = "pkill",
		stop_args = { "-SIGTERM", "ollama" },
	},
})

local function get_status_icon()
	local status = require("ollama").status()

	if status == "IDLE" then
		return "Ollama: [ IDLE ]"
	elseif status == "WORKING" then
		return "Ollama: [ BUSY ]"
	end
end
-- ollama end

require("lualine").setup({
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress", get_status_icon },
		lualine_z = { "location" },
	},
})

local ibl = require("ibl")
ibl.setup()
ibl.overwrite({
	exclude = { filetypes = { "python" } },
})

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

require("dressing").setup({
	input = {
		winoptions = {
			winhighlight = "NormalFloat:DiagnosticError",
		},
	},
})

local render_markdown = require("render-markdown")
render_markdown.setup({
	file_types = { "markdown", "Avante" },
})
vim.treesitter.language.register("markdown", "Avante")
render_markdown.enable()

require("avante").setup({
	provider = "claude-haiku",
	selector = {
		provider = "telescope",
	},
})

require("orgmode").setup({
	org_agenda_files = "~/Documents/notes/**/*",
	org_default_notes_file = "~/Documents/notes/refile.org",
})

require("nvim-treesitter.configs").setup({
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
})

-- terraform
vim.treesitter.language.register("terraform", { "terraform", "terraform-vars" })

-- rainbow brackets
vim.g.rainbow_active = 1
