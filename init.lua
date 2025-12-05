local vim = vim

function _G.Reload(...)
	return require("plenary.reload").reload_module(...)
end

function _G.R(name)
	Reload(name)
	return require(name)
end

require("options")
require("keymaps")

require("plugins.load")

require("navigation").setup()
require("refactor").setup()
require("compile.history")
require("compile.makefile").setup()
require("terminal").setup()
require("latex").setup()
require("gitmoji").setup()

local uname = vim.loop.os_uname()
if uname.sysname:find("Windows") then
	vim.cmd([[
        let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
        let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
        let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
        let &shellpipe  = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
        set shellquote= shellxquote=
    ]])
end

vim.api.nvim_create_user_command("Reload", function(opts)
	R(opts.args)
end, {
	nargs = 1,
})

-- Extra config hook - run at the end
local nvim_extra_config = os.getenv("NVIM_EXTRA_CONFIG")

if nvim_extra_config then
	dofile(nvim_extra_config)
end
