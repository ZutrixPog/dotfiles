return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
        local is_ok, toggleterm = pcall(require, "toggleterm")
        if not is_ok then
            return
        end

        toggleterm.setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<C-\>]], -- how to open a new terminal
            hide_numbers = true, -- hide the number column in toggleterm buffers
            close_on_exit = true, -- close the terminal window when the process exits
            shell = vim.o.shell, -- change the default shell
            direction = "float",
            float_opts = {
                -- The border key is *almost* the same as 'nvim_open_win'
                -- see :h nvim_open_win for details on borders however
                -- the 'curved' border is a custom border type
                -- not natively supported but implemented in this plugin.
                border = "single",

                winblend = 0,
            },
        })


        -- Define key mappings
        --  t: terminal mode
        function _G.set_terminal_keymaps()

            local opts = { noremap = true, buffer = 0 }
            -- Go back to the Normal model in terminal
            vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
            vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)

            vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)

            vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
        end

        -- If you only want these mappings for toggle term use term://*toggleterm#* instead
        vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")

        local Terminal = require("toggleterm.terminal").Terminal

        -- Create terminals for different modes
        local horizontal_term = Terminal:new({ direction = "horizontal" })
        local vertical_term = Terminal:new({ direction = "vertical" })
        local float_term = Terminal:new({ direction = "float" })

        function horizontal_term_toggle()
          horizontal_term:toggle()
        end
        function vertical_term_toggle()
          vertical_term:toggle()
        end
        function float_term_toggle()
          float_term:toggle()
        end

        -- Key mappings for opening different terminals
        vim.keymap.set({"n", "v", "i", "t"}, "<M-1>", "<cmd>lua horizontal_term_toggle()<CR>", { noremap = true, silent = true })
        vim.keymap.set({"n", "v", "i", "t"}, "<M-2>", "<cmd>lua vertical_term_toggle()<CR>", { noremap = true, silent = true })
        vim.keymap.set({"n", "v", "i", "t"}, "<M-3>", "<cmd>lua float_term_toggle()<CR>", { noremap = true, silent = true })


	end,
}
