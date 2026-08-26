local o = vim.o

o.statusline = '%!v:lua.StatusLine()'
o.laststatus = 3
o.cmdheight  = 0
o.showmode   = false

vim.g.qf_disable_statusline = 1

local function replace_keycode(keycode)
  return vim.api.nvim_replace_termcodes(keycode, true, false, true)
end

local modes = setmetatable({
  ['n']                      = { text = 'Normal',   hl = '%#StatusLineModeNormal#'  },
  ['v']                      = { text = 'Visual',   hl = '%#StatusLineModeVisual#'  },
  ['V']                      = { text = 'V-Line',   hl = '%#StatusLineModeVisual#'  },
  [replace_keycode('<C-v>')] = { text = 'V-Block',  hl = '%#StatusLineModeVisual#'  },
  ['s']                      = { text = 'Select',   hl = '%#StatusLineModeVisual#'  },
  ['S']                      = { text = 'S-Line',   hl = '%#StatusLineModeVisual#'  },
  [replace_keycode('<C-s>')] = { text = 'S-Block',  hl = '%#StatusLineModeVisual#'  },
  ['i']                      = { text = 'Insert',   hl = '%#StatusLineModeInsert#'  },
  ['R']                      = { text = 'Replace',  hl = '%#StatusLineModeReplace#' },
  ['c']                      = { text = 'Command',  hl = '%#StatusLineModeCommand#' },
  ['t']                      = { text = 'Terminal', hl = '%#StatusLineModeOther#'   },
}, {
  __index = function(self)
    return { text = 'Unknown', hl = self['t'].hl }
  end,
})

local info_hl = '%#StatusLineInfo#'

function _G.StatusLine()
  local parts = {}
  local buf = vim.api.nvim_get_current_buf()

  -- mode section
  local mode = modes[vim.fn.mode()]
  table.insert(parts, mode.hl .. ' ' .. mode.text .. ' ')

  -- devinfo section
  local devinfo_parts = { info_hl }

  local lsp_count = #vim.lsp.get_clients({ bufnr = buf })
  if lsp_count > 0 then table.insert(devinfo_parts, ' @' .. lsp_count) end

  local diag = vim.diagnostic.status(buf)
  if diag ~= '' then table.insert(devinfo_parts, ' ' .. diag) end

  if #devinfo_parts > 1 then
    table.insert(devinfo_parts, ' ')
    table.insert(parts, table.concat(devinfo_parts))
  end

  -- fname section
  table.insert(parts, '%* %f%m %=')

  -- fpos section
  table.insert(parts, mode.hl .. ' %l:%c%V ')

  return table.concat(parts)
end
