return {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        require("nvim-navic").setup({
            lsp = {
                auto_attach = true,
            },
        })
        -- vim.o.statusline = "%{%v:lua.require'nvim-navic'.get_location()%}"
    end
}
