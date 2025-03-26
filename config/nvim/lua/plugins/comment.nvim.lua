return {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()

        vim.keymap.set("n", "<leader>/", "gcc")
        vim.keymap.set("v", "<leader>/", "gbc")
    end
}
