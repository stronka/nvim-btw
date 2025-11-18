local vim = vim

require("ollama").setup {
	model = "codellama",
	stream = true,
	serve = {
		command = "ollama",
		args = { "serve" },
		stop_command = "pkill",
		stop_args = { "-SIGTERM", "ollama" },
	},
}

require("dressing").setup {
	input = {
		winoptions = {
			winhighlight = "NormalFloat:DiagnosticError",
		},
	},
}

local render_markdown = require("render-markdown")
render_markdown.setup {
	file_types = { "markdown", "Avante" },
}

vim.treesitter.language.register("markdown", "Avante")
render_markdown.enable()

require("avante").setup {
	provider = "claude-haiku",
	selector = {
		provider = "telescope",
	},
}
