local vim = vim

require("options")
require("keymaps")

require("plugins.load")

require("navigation").setup()
require("refactor").setup()
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

-- Extra config hook - run at the end
local nvim_extra_config = os.getenv("NVIM_EXTRA_CONFIG")

if nvim_extra_config then
	dofile(nvim_extra_config)
end
