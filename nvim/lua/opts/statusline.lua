local o = vim.o

o.statusline = '%{%v:lua.saff_statusline()%}'
o.laststatus = 3
o.cmdheight  = 0
o.showmode   = false

vim.g.qf_disable_statusline = 1

local modes = setmetatable({
  ['n'] = 'Normal',
  ['v'] = 'Visual',
  ['V'] = 'V-Line',
  [''] = 'V-Block',
  ['s'] = 'Select',
  ['S'] = 'S-Line',
  [''] = 'S-Block',
  ['i'] = 'Insert',
  ['R'] = 'Replace',
  ['c'] = 'Command',
  ['t'] = 'Terminal',
}, {
  __index = function()
    return 'Unknown'
  end,
})

function _G.saff_statusline()
  local parts = {}
  local buf = vim.api.nvim_get_current_buf()

  -- mode section
  local mode = modes[vim.fn.mode()]
  table.insert(parts, ' ' .. mode .. ' ')

  -- devinfo section
  local devinfo_parts = {}

  local lsp_count = #vim.lsp.get_clients({ bufnr = buf })
  if lsp_count > 0 then table.insert(devinfo_parts, ' @' .. lsp_count) end

  local diag = vim.diagnostic.status(buf)
  if diag ~= '' then table.insert(devinfo_parts, ' ' .. diag) end

  if #devinfo_parts > 0 then
    table.insert(devinfo_parts, ' ')
    table.insert(parts, table.concat(devinfo_parts))
  end

  -- fname section
  table.insert(parts, ' %f%m ')

  -- fpos section
  table.insert(parts, '%= %l:%c%V ')

  return table.concat(parts)
end
