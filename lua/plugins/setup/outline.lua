local vim = vim

local outline = require("outline")

local function setup_outline()
	outline.setup {
		symbols = {
			icon_fetcher = function(k)
				if k == "Package" then
					return ""
				end

				return false
			end,
			icon_source = "lspkind",
		},
		outline_window = {
			width = 25,
			relative_width = true,
		},
	}

	vim.keymap.set("n", "<leader>oo", function()
		vim.api.nvim_command("botright OutlineOpen")
	end, {})

	vim.keymap.set("n", "<leader>O", function()
		vim.api.nvim_command("OutlineClose")
	end, {})

	vim.keymap.set("n", "<leader>or", function()
		vim.api.nvim_command("OutlineRefresh")
	end, {})

	vim.keymap.set("n", "<leader>of", function()
		vim.api.nvim_command("OutlineFocus")
	end, {})
end

setup_outline()
