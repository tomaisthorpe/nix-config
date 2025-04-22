return {
    'stevearc/conform.nvim',
    keys = {
        {
            '<leader>f',
            function()
                require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = '',
            desc = '[F]ormat buffer',
        },
    },
    opts = {
        notify_on_error = true,
        format_on_save = {
            timeout_ms = 500,
            lsp_format = 'fallback',
        },
        formatters_by_ft = {
            lua = { 'stylua' },
            javascript = { "prettierd", "prettier", stop_after_first = true },
            typescript = { "prettierd", "prettier", stop_after_first = true },
            rust = { 'rustfmt' },
        },
    }
}
