local o       = vim.o
local keycode = vim.keycode
local api     = vim.api
local au      = api.nvim_create_autocmd

o.statusline = '%!v:lua.StatusLine()'
o.laststatus = 3
o.cmdheight  = 0
o.showmode   = false

vim.g.qf_disable_statusline = 1

---@type table<integer, { lsp_count: string }?>
local state   = {}
local group   = api.nvim_create_augroup('saff.statusline', { clear = true })

local modes = setmetatable({
  ['n']              = { text = 'Normal',   hl = '%#StatusLineModeNormal#'  },
  ['v']              = { text = 'Visual',   hl = '%#StatusLineModeVisual#'  },
  ['V']              = { text = 'V-Line',   hl = '%#StatusLineModeVisual#'  },
  [keycode('<C-v>')] = { text = 'V-Block',  hl = '%#StatusLineModeVisual#'  },
  ['s']              = { text = 'Select',   hl = '%#StatusLineModeVisual#'  },
  ['S']              = { text = 'S-Line',   hl = '%#StatusLineModeVisual#'  },
  [keycode('<C-s>')] = { text = 'S-Block',  hl = '%#StatusLineModeVisual#'  },
  ['i']              = { text = 'Insert',   hl = '%#StatusLineModeInsert#'  },
  ['R']              = { text = 'Replace',  hl = '%#StatusLineModeReplace#' },
  ['c']              = { text = 'Command',  hl = '%#StatusLineModeCommand#' },
  ['t']              = { text = 'Terminal', hl = '%#StatusLineModeOther#'   },
}, {
  __index = function(self)
    return { text = 'Unknown', hl = self['t'].hl }
  end,
})

local diag_lvls = {
  { text = 'E', hl = '%#StatusLineDiagnosticError#' },
  { text = 'W', hl = '%#StatusLineDiagnosticWarn#'  },
  { text = 'I', hl = '%#StatusLineDiagnosticInfo#'  },
  { text = 'H', hl = '%#StatusLineDiagnosticHint#'  },
}

local info_hl = '%#StatusLineInfo#'

local function section_diag(buf)
  local count = vim.diagnostic.count(buf)
  if vim.tbl_isempty(count) then return end
  local parts = {}
  for i, lvl in ipairs(diag_lvls) do
    local c = count[i]
    if c then
      table.insert(parts, ' ' .. lvl.hl .. lvl.text .. c)
    end
  end
  return table.concat(parts)
end

function _G.StatusLine()
  local parts = {}
  local buf = api.nvim_get_current_buf()

  -- mode section
  local mode = modes[vim.fn.mode()]
  table.insert(parts, mode.hl .. ' ' .. mode.text .. ' ')

  -- devinfo section
  local devinfo_parts = { info_hl }

  local lsp_count = #vim.lsp.get_clients({ bufnr = buf })
  if lsp_count > 0 then
    table.insert(devinfo_parts, ' @' .. lsp_count)
  end

  local diag = section_diag(buf)
  if diag then
    table.insert(devinfo_parts, diag)
  end

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

au('BufEnter', {
  group = group,
  callback = function(e)
    local buf = e.buf

    if not api.nvim_is_valid_buf(buf) then
      state[buf] = nil
      return
    end

    state[buf] = state[buf] or {}
  end,
})

au('BufWipeout', {
  group = group,
  callback = function(e)
    state[e.buf] = nil
  end
})
