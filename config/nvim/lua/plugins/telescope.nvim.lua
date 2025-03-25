return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
        local is_ok, builtin = pcall(require, "telescope.builtin")
        if not is_ok then

            return
        end


        vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
        vim.keymap.set("n", "<leader>fg", builtin.git_files, {})

        vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
        vim.keymap.set("n", "<leader>fs", builtin.live_grep, {}) -- NOTE: requires ripgrpe
        vim.keymap.set("n", "<leader>fc", function() -- fc = find by content
            builtin.grep_string({ search = vim.fn.input("Grep > ") })
        end)
	end,
}
