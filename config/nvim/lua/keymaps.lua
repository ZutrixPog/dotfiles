-- Define common options
vim.g.mapleader = "<Space>"
local opts = {
	noremap = true, -- non-recursive
	silent = true, -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)

vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)

vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- For nvim-tree.lua
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- For flash.nvim
-- 1. Press `s` and type jump label
-- 2. Press `S` and type jump label for specefic selection based on tree-sitter.
--    You can also use `;` or `,` to increase/decrease the selection

-- For nvim-surround
--     Old text                    Command         New text
-- --------------------------------------------------------------------------------
--     surr*ound_words             ysiw)           (surround_words)
--     *make strings               ys$"            "make strings"
--     [delete ar*ound me!]        ds]             delete around me!
--     remove <b>HTML t*ags</b>    dst             remove HTML tags
--     'change quot*es'            cs'"            "change quotes"

--     <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>


-----------------
-- Visual mode --
-----------------

vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- For toggleterm
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
