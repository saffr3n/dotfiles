local lsp_cmp_au = vim.api.nvim_create_augroup('lsp-cmp', { clear = true })
local is_lsp_cmp_on = false

vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_cmp_au,
  callback = function(event)
    vim.lsp.completion.enable(true, event.data.client_id, event.buf)

    vim.keymap.set('i', '<C-Space>', function()
      is_lsp_cmp_on = not is_lsp_cmp_on
      if is_lsp_cmp_on then
        vim.lsp.completion.get()
      else
        local ctrl_e = vim.api.nvim_replace_termcodes('<C-e>', true, false, true)
        vim.api.nvim_feedkeys(ctrl_e, 'n', false)
      end
    end, { buf = event.buf })

    vim.api.nvim_create_autocmd('TextChangedI', {
      group = lsp_cmp_au,
      callback = function()
        if is_lsp_cmp_on then vim.lsp.completion.get() end
      end,
    })

    vim.api.nvim_create_autocmd('InsertLeave', {
      group = lsp_cmp_au,
      callback = function()
        is_lsp_cmp_on = false
      end,
    })
  end,
})

local cmd_cmp_au = vim.api.nvim_create_augroup('wild-trigger', { clear = true })
local is_cmd_cmp_on = false

vim.keymap.set('c', '<C-Space>', function()
  is_cmd_cmp_on = not is_cmd_cmp_on
  if is_cmd_cmp_on then
    vim.fn.wildtrigger()
  else
    local ctrl_e = vim.api.nvim_replace_termcodes('<C-e>', true, false, true)
    vim.api.nvim_feedkeys(ctrl_e, 'n', false)
  end
end)

vim.api.nvim_create_autocmd('CmdlineChanged', {
  group = cmd_cmp_au,
  callback = function()
    if is_cmd_cmp_on then vim.fn.wildtrigger() end
  end,
})

vim.api.nvim_create_autocmd('CmdlineLeave', {
  group = cmd_cmp_au,
  callback = function()
    is_cmd_cmp_on = false
  end,
})
