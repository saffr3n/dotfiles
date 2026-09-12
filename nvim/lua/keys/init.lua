local g   = vim.g
local map = vim.keymap.set
local cmd = vim.cmd
local api = vim.api

g.mapleader      = ' '
g.maplocalleader = ' '

require('keys.emacs')

map('c', '<C-;>', '<C-f>') -- <C-f> is taken by emacs mappings

local mcursor_ns = api.nvim_create_namespace('nvim.multicursor')
map('n', '<Esc>', function()
  cmd.nohlsearch()
  api.nvim_buf_clear_namespace(0, mcursor_ns, 0, -1)
end)

map('n', 'j', 'gj')
map('n', 'k', 'gk')

map('x', '>', '>gv')
map('x', '<', '<gv')

map('n', '<Leader>e', ':20Lex<CR>')
map('n', '<Leader>u', cmd.Undotree)

map('n', '<Leader>q', vim.diagnostic.setqflist)
map('n', '<Leader>l', vim.diagnostic.setloclist)

map('n', '<M-j>', ':move +1<CR>==')
map('n', '<M-k>', ':move -2<CR>==')
map('x', '<M-j>', ":move '>+1<CR>gv=gv")
map('x', '<M-k>', ":move '<-2<CR>gv=gv")

map('n', '<C-h>', ':vertical   resize -1<CR>')
map('n', '<C-j>', ':horizontal resize -1<CR>')
map('n', '<C-k>', ':horizontal resize +1<CR>')
map('n', '<C-l>', ':vertical   resize +1<CR>')
