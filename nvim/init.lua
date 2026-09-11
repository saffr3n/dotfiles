vim.loader.enable()
require('vim._core.ui2').enable()
vim.cmd.colorscheme('tokyonight')
vim.cmd.packadd('nvim.undotree')

vim.pack.add({ 'https://github.com/saffr3n/meanwhile.nvim' })

require('opts')
require('keys')
require('indent')
require('treesitter')
require('completion')

vim.diagnostic.config({ severity_sort = true, virtual_text = true })


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
