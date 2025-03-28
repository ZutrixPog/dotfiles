-- Define common options
local opts = {
    noremap = true, -- non-recursive
    silent = true,  -- do not show message
}

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)
vim.keymap.set({ "n", "v", "i", "t" }, "<leader>qq", ":wqa<CR>", opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)

vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)

vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Better Editting
vim.keymap.set({ "n", "i", "x" }, "<leader>w", ":w!<CR>", opts)
vim.keymap.set("n", "<leader>fd", "_d", opts)
vim.keymap.set("n", "<leader>fd", "_d", opts)
vim.keymap.set("n", "<leader>fp", "_d", opts)

-- Centering Search Resutls
vim.keymap.set({ "n" }, "n", "nzz", opts)
vim.keymap.set({ "n" }, "p", "pzz", opts)

-- For nvim-tree.lua
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- visual mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- For Dashboard
vim.keymap.set("n", "<leader>vd", "<cmd>Dashboard<CR>", opts)

-- yank to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- delete without copy
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
