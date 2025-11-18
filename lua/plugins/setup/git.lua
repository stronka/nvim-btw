local vim = vim

require("gitsigns").setup()

require("neogit").setup {}

local neogit_setup = function()
	local neogit = require("neogit")
	vim.keymap.set("n", "<F5>", neogit.open)
end

neogit_setup()
