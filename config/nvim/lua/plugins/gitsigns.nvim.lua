return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require('gitsigns').setup {
            auto_attach = true,
            attach_to_untracked = false,
            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        }
    end
}
