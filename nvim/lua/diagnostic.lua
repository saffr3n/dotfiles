local diagnostic = vim.diagnostic

vim.keymap.set('n', '<Leader>q', diagnostic.setloclist)

diagnostic.config({
  severity_sort = true,
  virtual_text  = true,
  jump          = {
    on_jump = function(_, buf)
      diagnostic.open_float({
        bufnr = buf,
        scope = 'cursor',
        focus = false,
      })
    end,
  },
})
