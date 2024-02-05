return {
    "mfussenegger/nvim-lint",
    version = "*",
    config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
            javascript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescript = { "eslint_d" },
            typescriptreact = { "eslint_d" },
        }

        vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
            group = vim.api.nvim_create_augroup('lint', { clear = true }),
            callback = function()
                lint.try_lint()
            end,
        })
    end,
}
