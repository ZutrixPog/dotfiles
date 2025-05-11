return {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()

        vim.keymap.set('n', '<leader>c', 'gcc', { remap = true })
        vim.keymap.set('x', '<leader>c', 'gc', { remap = true })
    end
}
