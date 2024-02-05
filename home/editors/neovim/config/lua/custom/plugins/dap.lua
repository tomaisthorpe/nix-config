return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "leoluz/nvim-dap-go"
    },
    config = function()
        require("dapui").setup()
        require('dap-go').setup()

        local dap, dapui = require("dap"), require("dapui")
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        vim.keymap.set('n', '<leader>tb', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
        vim.keymap.set('n', '<F5>', dap.continue, { desc = 'DAP: Continue' })
        vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP: Step Over' })
        vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP: Step Into' })
        vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'DAP: Step Out' })

        dap.adapters.delve = {
            type = 'server',
            port = '${port}',
            executable = {
                command = 'dlv',
                args = { 'dap', '-l', '127.0.0.1:${port}' },
            }
        }

        -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
        dap.configurations.go = {
            {
                type = "delve",
                name = "Debug",
                request = "launch",
                program = "${file}"
            },
            {
                type = "delve",
                name = "Debug test", -- configuration for debugging test files
                request = "launch",
                mode = "test",
                program = "${file}"
            },
            -- works with go.mod packages and sub packages
            {
                type = "delve",
                name = "Debug test (go.mod)",
                request = "launch",
                mode = "test",
                program = "./${relativeFileDirname}"
            }
        }
    end
}
