local M = {}
local vim = vim

local insert_gitmoji = function()
	local function search(query)
		if query == nil or query == "" then
			return
		end

		local cmd = { "gitmoji" }

		for item in query:gmatch("[^%s]+") do
			table.insert(cmd, item)
		end

		table.insert(cmd, "-s")

		local obj = vim.system(cmd):wait()
		local emoji = vim.fn.strcharpart(obj.stdout, 0, 1)

		vim.api.nvim_put({ emoji }, "c", true, true)
	end

	vim.ui.input({ prompt = "Enter gitmoji query: " }, search)
end

M.setup = function()
	vim.keymap.set({ "n", "i" }, "<Leader>gm", insert_gitmoji)
end

return M
