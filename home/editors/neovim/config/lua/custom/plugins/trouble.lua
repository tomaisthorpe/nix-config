return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below


    },
    config = function()
        -- document existing key chains
        require('which-key').add({
            { '<leader>x', group = 'Diagnostics' },
        })
        
        vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = 'Toggle Trouble' })
        vim.keymap.set("n", "<leader>xw", function() require("trouble").toggle("workspace_diagnostics") end,
            { desc = 'Toggle Workspace Trouble' })
        vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("document_diagnostics") end,
            { desc = 'Toggle Document Trouble' })
    end
}
