local vim = vim

local dap = require("dap")
local dapui = require("dapui")

require("nvim-dap-virtual-text").setup()

dapui.setup()

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = 'Local Script',
        program = '${file}',
    },
    {
        type = 'python',
        request = 'attach',
        name = 'Attach to Django (Docker)',
        connect = {
            host = '127.0.0.1',
            port = 5678,
        },
        mode = 'remote',
        pathMappings = {
            {
                localRoot = vim.fn.getcwd(),
                remoteRoot = '/app',
            }
        }
    },
    {
        type = 'python',
        request = 'attach',
        name = 'Attach to Celery (Docker)',
        connect = {
            host = '127.0.0.1',
            port = 5679,
        },
        mode = 'remote',
        pathMappings = {
            {
                localRoot = vim.fn.getcwd(),
                remoteRoot = '/app',
            }
        }
    },
    {
        type = 'python',
        request = 'attach',
        name = 'Attach to pytest (Docker)',
        connect = {
            host = '127.0.0.1',
            port = 5680,
        },
        mode = 'remote',
        pathMappings = {
            {
                localRoot = vim.fn.getcwd(),
                remoteRoot = '/app',
            }
        }
    }
}

require("dap-python").setup("python3")

vim.keymap.set('n', '<Leader>dn', ':DapNew<CR>')
vim.keymap.set('n', '<Leader>dc', function() dap.continue() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)
vim.keymap.set('n', '<Leader>db', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>dB', function() dap.set_breakpoint() end)
vim.keymap.set('n', '<Leader>dp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end)
vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)
