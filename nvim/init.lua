vim.loader.enable()
require('vim._core.ui2').enable()
vim.cmd.colorscheme('tokyonight')
vim.cmd.packadd('nvim.undotree')

vim.diagnostic.config({ severity_sort = true, virtual_text = true })

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('i', '<C-p>', function()
  local key = vim.api.nvim_replace_termcodes(vim.fn.pumvisible() == 0 and '<Up>' or '<C-p>', true, false, true)
  vim.api.nvim_feedkeys(key, 'n', false)
end)
vim.keymap.set('i', '<C-n>', function()
  local key = vim.api.nvim_replace_termcodes(vim.fn.pumvisible() == 0 and '<Down>' or '<C-n>', true, false, true)
  vim.api.nvim_feedkeys(key, 'n', false)
end)
vim.keymap.set({ 'i', 'c' }, '<C-b>', '<Left>')
vim.keymap.set({ 'i', 'c' }, '<C-f>', '<Right>')
vim.keymap.set({ 'i', 'c' }, '<M-b>', '<S-Left>')
vim.keymap.set({ 'i', 'c' }, '<M-f>', '<S-Right>')
vim.keymap.set({ 'i', 'c' }, '<C-a>', '<Home>')
vim.keymap.set({ 'i', 'c' }, '<C-e>', function()
  local key = vim.api.nvim_replace_termcodes(vim.fn.pumvisible() == 0 and '<End>' or '<C-e>', true, false, true)
  vim.api.nvim_feedkeys(key, 'n', false)
end)
vim.keymap.set({ 'i', 'c' }, '<C-d>', '<Del>')
vim.keymap.set('i', '<M-d>', '<C-o>dw')
vim.keymap.set('i', '<C-k>', '<C-o>D')
vim.keymap.set('c', '<M-d>', function()
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  local before = line:sub(1, pos - 1)
  local after = line:sub(pos)
  after = after:gsub('^%w+', '', 1)
  after = after:gsub('^%s+', '', 1)
  vim.fn.setcmdline(before .. after, pos)
end)
vim.keymap.set('c', '<C-k>', function()
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  vim.fn.setcmdline(line:sub(1, pos - 1), pos)
end)
vim.keymap.set('n', '<M-j>', ':move +1<CR>==')
vim.keymap.set('n', '<M-k>', ':move -2<CR>==')
vim.keymap.set('x', '<M-j>', ":move '>+1<CR>gv=gv")
vim.keymap.set('x', '<M-k>', ":move '<-2<CR>gv=gv")
vim.keymap.set('x', '>', '>gv')
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('n', '[t', vim.cmd.tabprevious)
vim.keymap.set('n', ']t', vim.cmd.tabnext)
vim.keymap.set('n', '<Esc>', vim.cmd.nohlsearch)
vim.keymap.set('n', '<Leader>u', vim.cmd.Undotree)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setqflist)
vim.keymap.set('n', '<Leader>l', vim.diagnostic.setloclist)
vim.keymap.set('n', '<C-h>', ':vertical resize -1<CR>')
vim.keymap.set('n', '<C-j>', ':horizontal resize -1<CR>')
vim.keymap.set('n', '<C-k>', ':horizontal resize +1<CR>')
vim.keymap.set('n', '<C-l>', ':vertical resize +1<CR>')
vim.keymap.set('n', '<Leader>e', ':20Lex<CR>')

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_sizestyle = 'H'
vim.g.netrw_altfile = 1
vim.g.netrw_browse_split = 4
vim.o.title = true
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
vim.o.winborder = 'rounded'
vim.o.pumborder = 'rounded'
vim.o.list = true
vim.o.listchars = 'trail:·,nbsp:·'
vim.o.fillchars = 'eob: '
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
vim.o.completeopt = 'menuone,noselect,fuzzy,popup'
vim.o.wildmode = 'noselect:lastused,full'
vim.o.wildoptions = 'pum,tagfile,fuzzy'
vim.o.cmdheight = 0
vim.opt.path:append("**")

---@type [integer, integer]?
local cur_pre_yank
vim.keymap.set({ 'n', 'x' }, 'y', function()
  cur_pre_yank = vim.api.nvim_win_get_cursor(0)
  return 'y'
end, { expr = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('yank', { clear = true }),
  callback = function()
    vim.hl.hl_op()
    if not cur_pre_yank then return end
    vim.api.nvim_win_set_cursor(0, cur_pre_yank)
    cur_pre_yank = nil
  end,
})

vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })
require('nvim-treesitter').install({ 'nix', 'java' })
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('ts-start', { clear = true }),
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match)
    if not lang or not vim.treesitter.language.add(lang) then return end
    vim.treesitter.start(event.buf, lang)
  end,
})

for _, file in ipairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
  local name = vim.fn.fnamemodify(file, ':t:r')
  vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    ---@param mode string | string[]
    ---@param lhs string
    ---@param rhs string | function
    local function map(mode, lhs, rhs) vim.keymap.set(mode, lhs, rhs, { buffer = event.buf }) end
    map('i', '<C-Space>', vim.lsp.completion.get)
    map('n', '<Leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end)
    vim.lsp.completion.enable(true, event.data.client_id, event.buf)
  end,
})
