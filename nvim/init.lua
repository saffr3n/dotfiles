vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('n', '<Esc>', vim.cmd.nohlsearch)

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.laststatus = 3
vim.o.scrolloff = 8
vim.o.cursorline = true
vim.o.breakindent = true
vim.o.linebreak = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.listchars = 'trail:·,nbsp:·'
vim.o.shiftwidth = 2
vim.o.softtabstop = -1
vim.o.expandtab = true
vim.o.confirm = true
vim.o.undofile = true
vim.o.backupcopy = 'yes'
vim.o.clipboard = 'unnamedplus'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = 'split'

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('yank-hl', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})
