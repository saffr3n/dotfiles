vim.loader.enable()
require('vim._core.ui2').enable()
vim.cmd.colorscheme('tokyonight')
vim.cmd.packadd('nvim.undotree')

vim.pack.add({ 'https://github.com/saffr3n/meanwhile.nvim' })

require('opts')
require('treesitter')
require('completion')

vim.diagnostic.config({ severity_sort = true, virtual_text = true })

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('i', '<C-p>', function() return vim.fn.pumvisible() == 0 and '<Up>' or '<C-p>' end, { expr = true })
vim.keymap.set('i', '<C-n>', function() return vim.fn.pumvisible() == 0 and '<Down>' or '<C-n>' end, { expr = true })
vim.keymap.set({ 'i', 'c' }, '<C-b>', '<Left>')
vim.keymap.set({ 'i', 'c' }, '<C-f>', '<Right>')
vim.keymap.set({ 'i', 'c' }, '<M-b>', '<S-Left>')
vim.keymap.set({ 'i', 'c' }, '<M-f>', '<S-Right>')
vim.keymap.set({ 'i', 'c' }, '<C-a>', '<Home>')
vim.keymap.set({ 'i', 'c' }, '<C-e>', function() return vim.fn.pumvisible() == 0 and '<End>' or '<C-e>' end, { expr = true })
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
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
vim.keymap.set('c', '<C-;>', '<C-f>')
vim.keymap.set('n', '<M-j>', ':move +1<CR>==')
vim.keymap.set('n', '<M-k>', ':move -2<CR>==')
vim.keymap.set('x', '<M-j>', ":move '>+1<CR>gv=gv")
vim.keymap.set('x', '<M-k>', ":move '<-2<CR>gv=gv")
vim.keymap.set('x', '>', '>gv')
vim.keymap.set('x', '<', '<gv')
vim.keymap.set('n', '<Esc>', vim.cmd.nohlsearch)
vim.keymap.set('n', '<Leader>u', vim.cmd.Undotree)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setqflist)
vim.keymap.set('n', '<Leader>l', vim.diagnostic.setloclist)
vim.keymap.set('n', '<C-h>', ':vertical resize -1<CR>')
vim.keymap.set('n', '<C-j>', ':horizontal resize -1<CR>')
vim.keymap.set('n', '<C-k>', ':horizontal resize +1<CR>')
vim.keymap.set('n', '<C-l>', ':vertical resize +1<CR>')
vim.keymap.set('n', '<Leader>e', ':20Lex<CR>')

---@type [integer, integer]?
local cur_pre_yank
vim.keymap.set({ 'n', 'x' }, 'y', function()
  cur_pre_yank = vim.api.nvim_win_get_cursor(0)
  return 'y'
end, { expr = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('saff.yank', { clear = true }),
  callback = function()
    vim.hl.hl_op()
    if not cur_pre_yank then return end
    vim.api.nvim_win_set_cursor(0, cur_pre_yank)
    cur_pre_yank = nil
  end,
})

for _, file in ipairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
  local name = vim.fn.fnamemodify(file, ':t:r')
  vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('saff.lsp', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', '<Leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, { buf = event.buf })
  end,
})

function _G.TabLine()
  local s = ''
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local hl, cross = '', ''
    if tab == vim.api.nvim_get_current_tabpage() then
      hl = '%#TabLineSel#'
      cross = '%999Xx'
    else
      hl = '%#TabLine#'
    end

    local n = vim.api.nvim_tabpage_get_number(tab)
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)

    local name_full = vim.api.nvim_buf_get_name(buf)
    if name_full == '' then name_full = '[No Name]' end
    local name_short = vim.fn.fnamemodify(name_full, ':t')
    local name = name_short == '' and name_full or name_short

    s = s .. hl .. '%' .. n .. 'T' .. ' ' .. name .. ' ' .. cross .. ' '
  end
  s = s .. '%#TabLineFill#%T'
  return s
end
vim.o.tabline = '%{%v:lua.TabLine()%}'
