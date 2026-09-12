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

---@type table<integer, {
---  lsp_count  : string,
---  diag_count : string,
---  fsize      : string,
---}?>
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
  local buf   = api.nvim_get_current_buf()
  local s     = state[buf]

  local lsp_count  = ''
  local diag_count = ''
  local fsize      = ''

  if s then
    lsp_count  = s.lsp_count
    diag_count = s.diag_count
    fsize      = s.fsize
  end

  -- mode section
  local mode = modes[vim.fn.mode()]
  table.insert(parts, mode.hl .. ' ' .. mode.text .. ' ')

  -- devinfo section
  local devinfo_parts = { info_hl }

  if lsp_count  ~= '' then
    table.insert(devinfo_parts, lsp_count)
  end
  if diag_count ~= '' then
    table.insert(devinfo_parts, diag_count)
  end

  if #devinfo_parts > 1 then
    table.insert(devinfo_parts, ' ')
    table.insert(parts, table.concat(devinfo_parts))
  end

  -- fname section
  table.insert(parts, '%* %f%m %=')

  -- finfo section
  local finfo_parts = { info_hl }

  local ftype   = bo.filetype
  local fencode = bo.fileencoding
  local fformat = bo.fileformat

  if ftype ~= '' then
    table.insert(finfo_parts, ' ' .. ftype)
  end

  table.insert(finfo_parts, ' ' .. fencode .. '[' .. fformat .. '] ')

  if fsize ~= '' then
    table.insert(finfo_parts, fsize .. ' ')
  end

  table.insert(parts, table.concat(finfo_parts))

  -- fpos section
  table.insert(parts, mode.hl .. ' %l:%c%V ')

  return table.concat(parts)
end

local function clear(buf)
  state[buf] = nil
end

local function redraw(buf)
  api.nvim__redraw({ buf = buf, statusline = true })
end

---@param buf integer
local function update_lsp_count(buf)
  -- lsp client list doesn't get immediately updated on LspDetach, thus schedule
  vim.schedule(function()
    if not is_valid_buf(buf) then
      return clear(buf)
    end

    local s = state[buf]
    if not s then return end

    local count = #vim.lsp.get_clients({ bufnr = buf })
    s.lsp_count = count > 0 and (' @' .. count) or ''
    redraw(buf)
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
  redraw(buf)
end

---@param buf integer
local function update_fsize(buf)
  local s = state[buf]
  if not s then return end

  local lines = api.nvim_buf_line_count(buf)
  local bytes = api.nvim_buf_get_offset(buf, lines)

  local KB = 1024
  local MB = KB ^ 2

  if bytes < KB then
    s.fsize = bytes .. 'B'
  elseif bytes < MB then
    local kbytes = math.floor(bytes * 100 / KB) / 100
    s.fsize      = kbytes .. 'KB'
  else
    local mbytes = math.floor(bytes * 100 / MB) / 100
    s.fsize      = mbytes .. 'MB'
  end

  redraw(buf)
end

au('BufEnter', {
  group    = group,
  callback = function(e)
    local buf = e.buf

    if not is_valid_buf(buf) then
      return clear(buf)
    end

    state[buf] = state[buf] or {
      lsp_count  = '',
      diag_count = '',
      fsize      = '',
    }

    api.nvim_buf_attach(buf, false, {
      on_lines  = function() update_fsize(buf) end,
      on_reload = function() update_fsize(buf) end,
      on_detach = function() clear(buf)        end,
    })

    update_fsize(buf)
  end,
})

au('BufWipeout', {
  group    = group,
  callback = function(e)
    clear(e.buf)
  end
})

au({ 'LspAttach', 'LspDetach' }, {
  group    = group,
  callback = function(e)
    update_lsp_count(e.buf)
  end
})

au('DiagnosticChanged', {
  group    = group,
  callback = function(e)
    update_diag_count(e.buf)
  end,
})
