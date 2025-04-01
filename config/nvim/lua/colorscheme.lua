local colorscheme = 'gruvbox-material'

vim.g.gruvbox_material_background = 'soft'
vim.g.gruvbox_material_enable_italic = '1'
vim.g.gruvbox_material_cursor = 'orange'

local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not is_ok then
    vim.notify('colorscheme ' .. colorscheme .. ' not found!')
    return
end
