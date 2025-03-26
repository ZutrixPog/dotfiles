local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand
vim.api.nvim_create_augroup('bufcheck', {clear = true})

vim.api.nvim_create_augroup('bufcheck', {clear = true})

-- Highlight Cursor after Switching to a new buffer
autocmd("FocusGained", {
    pattern = "*",
    callback = function()
        vim.opt.cursorline = true
        vim.cmd("redraw")
        vim.defer_fn(function()
            vim.opt.cursorline = false
        end, 600)
    end,
    group = vim.telemachus_augroup,
})

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' })
  end
})

-- Remove whitespace on save
autocmd('BufWritePre', {
  pattern = '',
  command = ":%s/\\s\\+$//e"
})

-- Don't auto commenting new lines
autocmd('BufEnter', {
  pattern = '',
  command = 'set fo-=c fo-=r fo-=o'
})

-- reload config file on change
vim.api.nvim_create_autocmd('BufWritePost', {
    group    = 'bufcheck',
    pattern  = vim.env.MYVIMRC,
    command  = 'silent source %'})

-----------------------------------------------------------
-- Terminal settings
-----------------------------------------------------------

-- Enter insert mode when switching to terminal
autocmd('TermOpen', {
  command = 'setlocal listchars= nonumber norelativenumber nocursorline',
})

autocmd('TermOpen', {
  pattern = '',
  command = 'startinsert'
})

-- Close terminal buffer on process exit
autocmd('BufLeave', {
  pattern = 'term://*',
  command = 'stopinsert'
})
