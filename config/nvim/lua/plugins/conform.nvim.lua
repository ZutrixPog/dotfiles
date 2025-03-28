return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = {
            lua = { "stylua" },
            rust = { "rustfmt", lsp_format = "fallback" },
            c = { "clang-format" },
            cpp = { "clang-format" },
            python = function(bufnr)
                if require("conform").get_formatter_info("ruff_format", bufnr).available then
                    return { "ruff_format" }
                else
                    return { "black" }
                end
            end,
            go = { "gofumpt" },
        },
        format_on_save = {
            timeout_ms = 300,
            lsp_format = "fallback",
        },
    },
}
