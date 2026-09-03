local o            = vim.o
local bo           = vim.bo
local keycode      = vim.keycode
local api          = vim.api
local au           = api.nvim_create_autocmd
local is_valid_buf = api.nvim_buf_is_valid

o.statusline = '%{%v:lua.SaffStatusLine()%}'
o.laststatus = 3
o.cmdheight  = 0
o.showmode   = false

vim.g.qf_disable_statusline = 1

---@type table<integer, { lsp_count: string, diag_count: string }?>
local state   = {}
local group   = api.nvim_create_augroup('saff.statusline', { clear = true })
local info_hl = '%#SaffStatusLineInfo#'

local modes = setmetatable({
  ['n']              = { text = 'Normal',   hl = '%#SaffStatusLineModeNormal#'  },
  ['v']              = { text = 'Visual',   hl = '%#SaffStatusLineModeVisual#'  },
  ['V']              = { text = 'V-Line',   hl = '%#SaffStatusLineModeVisual#'  },
  [keycode('<C-v>')] = { text = 'V-Block',  hl = '%#SaffStatusLineModeVisual#'  },
  ['s']              = { text = 'Select',   hl = '%#SaffStatusLineModeVisual#'  },
  ['S']              = { text = 'S-Line',   hl = '%#SaffStatusLineModeVisual#'  },
  [keycode('<C-s>')] = { text = 'S-Block',  hl = '%#SaffStatusLineModeVisual#'  },
  ['i']              = { text = 'Insert',   hl = '%#SaffStatusLineModeInsert#'  },
  ['R']              = { text = 'Replace',  hl = '%#SaffStatusLineModeReplace#' },
  ['c']              = { text = 'Command',  hl = '%#SaffStatusLineModeCommand#' },
  ['t']              = { text = 'Terminal', hl = '%#SaffStatusLineModeOther#'   },
}, {
  __index = function(self)
    return { text = 'Unknown', hl = self['t'].hl }
  end,
})

local diag_lvls = {
  { text = 'E', hl = '%#SaffStatusLineDiagnosticError#' },
  { text = 'W', hl = '%#SaffStatusLineDiagnosticWarn#'  },
  { text = 'I', hl = '%#SaffStatusLineDiagnosticInfo#'  },
  { text = 'H', hl = '%#SaffStatusLineDiagnosticHint#'  },
}

function _G.SaffStatusLine()
  local parts = {}
  local buf = api.nvim_get_current_buf()

  -- mode section
  local mode = modes[vim.fn.mode()]
  table.insert(parts, mode.hl .. ' ' .. mode.text .. ' ')

  -- devinfo section
  local devinfo_parts = { info_hl }

  local s = state[buf]
  if s then
    if s.lsp_count ~= '' then table.insert(devinfo_parts, s.lsp_count) end
    if s.diag_count ~= '' then table.insert(devinfo_parts, s.diag_count) end
  end

  if #devinfo_parts > 1 then
    table.insert(devinfo_parts, ' ')
    table.insert(parts, table.concat(devinfo_parts))
  end

  -- fname section
  table.insert(parts, '%* %f%m %=')

  -- finfo section
  local ftype   = bo.filetype
  local fencode = bo.fileencoding
  local fformat = bo.fileformat

  if ftype ~= '' then ftype = ftype .. ' ' end

  table.insert(parts,
    info_hl .. ' ' ..
    ftype ..
    fencode ..
    '[' .. fformat .. '] %a'
  )

  -- fpos section
  table.insert(parts, mode.hl .. ' %l:%c%V ')

  return table.concat(parts)
end

local function clear_buf(buf)
  state[buf] = nil
end

---@param buf integer
local function update_lsp_count(buf)
  -- lsp client list doesn't get immediately updated on LspDetach, thus schedule
  vim.schedule(function()
    if not is_valid_buf(buf) then
      return clear_buf(buf)
    end

    local s = state[buf]
    if not s then return end

    local count = #vim.lsp.get_clients({ bufnr = buf })
    s.lsp_count = count > 0 and (' @' .. count) or ''
    api.nvim__redraw({ buf = buf, statusline = true })
  end)
end

---@param buf integer
local function update_diag_count(buf)
  local s = state[buf]
  if not s then return end
  
  local count = vim.diagnostic.count(buf) ---@as [integer?, integer?, integer?, integer?]
  local parts = {}

  for i, lvl in ipairs(diag_lvls) do
    local c = count[i]
    if c then
      table.insert(parts, ' ' .. lvl.hl .. lvl.text .. c)
    end
  end

  s.diag_count = table.concat(parts)
  api.nvim__redraw({ buf = buf, statusline = true })
end

au('BufEnter', {
  group = group,
  callback = function(e)
    local buf = e.buf

    if not is_valid_buf(buf) then
      return clear_buf(buf)
    end

    state[buf] = state[buf] or {
      lsp_count  = '',
      diag_count = '',
    }
  end,
})

au('BufWipeout', {
  group = group,
  callback = function(e)
    clear_buf(e.buf)
  end
})

au({ 'LspAttach', 'LspDetach' }, {
  group = group,
  callback = function(e)
    update_lsp_count(e.buf)
  end
})

au('DiagnosticChanged', {
  group = group,
  callback = function(e)
    update_diag_count(e.buf)
  end,
})
