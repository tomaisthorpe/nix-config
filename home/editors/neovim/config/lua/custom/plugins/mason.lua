local tools = {
    -- LSP
    'gopls',
    'html-lsp',
    'json-lsp',
    'lua-language-server',
    'pyright',
    'rust-analyzer',
    'typescript-language-server',
    'yaml-language-server',

    -- DAP
    'delve',

    -- Linter
    'golangci-lint',
    'markdownlint',
    'eslint_d',

    -- Formatter
    'goimports',
    'gofumpt',
    'stylua',
    'prettierd',
}

return {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
        require('mason').setup()
        require('mason-tool-installer').setup({
            ensure_installed = tools,
            auto_update = true,
            run_on_start = true,
        })
    end
}

