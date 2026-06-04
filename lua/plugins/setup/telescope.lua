local vim = vim

local telescope = require("telescope")
telescope.setup {
	defaults = {
		file_ignore_patterns = {
			"node_modules",
		},
		mappings = {
			i = {
				["<C-d>"] = require("telescope.actions").delete_buffer,
			},
			n = {
				["<C-d>"] = require("telescope.actions").delete_buffer,
			},
		},
	},
}

local telescope_builtin = require("telescope.builtin")

local function telescope_setup()
	local themes = require("telescope.themes")

	local function with_theme(func)
		return function(opts)
			func(opts)
		end
	end

	vim.keymap.set("n", "<leader>fm", with_theme(telescope_builtin.marks), {})
	vim.keymap.set("n", "<leader>fk", with_theme(telescope_builtin.keymaps), {})
	vim.keymap.set("n", "<leader>fs", with_theme(telescope_builtin.lsp_document_symbols), {})
	vim.keymap.set("n", "<leader>fr", with_theme(telescope_builtin.lsp_references), {})
	vim.keymap.set("n", "<leader>fh", with_theme(telescope_builtin.help_tags), {})
	vim.keymap.set("n", "<leader>fb", with_theme(telescope_builtin.buffers), {})
	vim.keymap.set("n", "<leader>fg", with_theme(telescope_builtin.live_grep), {})
	vim.keymap.set("n", "<leader>ff", with_theme(telescope_builtin.find_files), {})
	vim.keymap.set("n", "<leader>fj", with_theme(telescope_builtin.jumplist), {})
	vim.keymap.set("n", "<leader>fo", with_theme(telescope_builtin.oldfiles), {})
	vim.keymap.set("n", "<leader>fc", with_theme(telescope_builtin.command_history), {})
	vim.keymap.set("n", "<leader>fv", with_theme(telescope_builtin.git_status), {})

	vim.keymap.set("n", "<leader>fa", function()
		with_theme(telescope_builtin.find_files) {
			hidden = true,
			no_ignore = true,
		}
	end, {})

	vim.keymap.set("n", "<leader>fw", function()
		with_theme(telescope_builtin.grep_string) {
			search = vim.fn.expand("<cword>"),
		}
	end, {})
end

telescope_setup()
