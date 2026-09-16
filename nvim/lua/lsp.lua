local lsp = vim.lsp
local api = vim.api

for _, file in ipairs(api.nvim_get_runtime_file('lsp/*.lua', true)) do
  local name = vim.fn.fnamemodify(file, ':t:r')
  lsp.enable(name)
end

api.nvim_create_autocmd('LspAttach', {
  group    = api.nvim_create_augroup('saff.lsp', { clear = true }),
  callback = function(e)
    ---@param lhs string
    ---@param rhs string | function
    local function map(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { buf = e.buf })
    end

    map('grd', lsp.buf.definition)
    map('grD', lsp.buf.declaration)
    map('gW',  lsp.buf.workspace_symbol)

    map('<Leader>th', function()
      lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled())
    end)
  end,
})
