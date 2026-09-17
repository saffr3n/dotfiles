local cmd = vim.cmd

vim.loader.enable()
require('vim._core.ui2').enable()
cmd.colorscheme('tokyonight')

cmd.packadd('nvim.undotree')
vim.pack.add({ 'https://github.com/saffr3n/meanwhile.nvim' })

require('opts')
require('keys')
require('yank')
require('treesitter')
require('indent')
require('lsp')
require('completion')
require('diagnostic')
