local function get_status_icon()
	local status = require("ollama").status()

	if status == "IDLE" then
		return "Ollama: [ IDLE ]"
	elseif status == "WORKING" then
		return "Ollama: [ BUSY ]"
	end
end

require("lualine").setup {
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress", get_status_icon },
		lualine_z = { "location" },
	},
}
