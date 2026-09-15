vim.loader.enable()
require('vim._core.ui2').enable()
vim.cmd.colorscheme('tokyonight')
vim.cmd.packadd('nvim.undotree')

vim.pack.add({ 'https://github.com/saffr3n/meanwhile.nvim' })

require('opts')
require('keys')
require('yank')
require('indent')
require('treesitter')
require('completion')
require('diagnostic')



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
