local colorscheme = 'everforest'

vim.g.everforest_enable_italic = true
vim.g.everforest_background = "hard"

local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_ok then
    vim.notify('colorscheme ' .. colorscheme .. ' not found!')
    return
end
