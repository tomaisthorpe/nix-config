return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-go",
    },
    config = function()
        -- get neotest namespace (api call creates or returns namespace)
        local neotest_ns = vim.api.nvim_create_namespace("neotest")
        vim.diagnostic.config({
            virtual_text = {
                format = function(diagnostic)
                    local message =
                        diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
                    return message
                end,
            },
        }, neotest_ns)

        require("neotest").setup({
            adapters = {
                require("neotest-go")({
                    experimental = {
                        test_table = true,
                    },
                    args = { '-count=1' }
                })
            },
            diagnostics = {
                enabled = true,
            }
        })

        require('which-key').register {
            ['<leader>t'] = { name = 'Tests', _ = 'which_key_ignore' },
        }

        local nt = require("neotest")
        vim.keymap.set("n", "<leader>tt", function() nt.run.run() end, { desc = 'Run Nearest Test' })
        vim.keymap.set('n', '<leader>tn', function() nt.run.stop() end, { desc = 'Stop Nearest Test' })

        vim.keymap.set("n", "<leader>td", function()
                if vim.bo.filetype == 'go' then
                    require("dap-go").debug_test()
                else
                    nt.run.run({ strategy = "dap" })
                end
            end,
            { desc = 'Debug Nearest Test' })

        vim.keymap.set('n', '<leader>tp', require("dap-go").debug_last_test, { desc = 'Debug nearest test (Go)' })

        vim.keymap.set("n", "<leader>tf", function() nt.run.run(vim.fn.expand("%")) end,
            { desc = 'Test Current File' })
        vim.keymap.set('n', '<leader>to', function() nt.output_panel.toggle() end, { desc = 'Test outputs' })
        vim.keymap.set('n', '<leader>ts', function() nt.summary.toggle() end, { desc = 'Test summary' })
    end
}
