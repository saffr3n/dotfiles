vim.cmd.highlight('clear')
if vim.fn.exists('syntax_on') then
  vim.cmd.syntax('reset')
end

vim.g.colors_name = 'tokyonight'

local mode = vim.o.background

---@class (private) Palette
local palette = {
  neutral1 = { dark = '#15161e', light = '#b4b5b9' },
  neutral2 = { dark = '#16161e', light = '#d0d5e3' },
  neutral3 = { dark = '#1a1b26', light = '#e1e2e7' },
  neutral4 = { dark = '#1f2231', light = '#d5d9e4' },
  neutral5 = { dark = '#292e42', light = '#c4c8da' },
  neutral6 = { dark = '#3b4261', light = '#a8aecb' },

  muted1   = { dark = '#283457', light = '#b7c1e3' },
  muted2   = { dark = '#394b70', light = '#92a6d5' },
  muted3   = { dark = '#545c7e', light = '#8990b3' },
  muted4   = { dark = '#565f89', light = '#848cb5' },
  muted5   = { dark = '#a9b1d6', light = '#6172b0' },
  muted6   = { dark = '#c0caf5', light = '#3760bf' },

  blue1    = { dark = '#3d59a1', light = '#7890dd' },
  blue2    = { dark = '#6183bb', light = '#506d9c' },
  blue3    = { dark = '#7aa2f7', light = '#2e7de9' },

  cyan1    = { dark = '#0db9d7', light = '#07879d' },
  cyan2    = { dark = '#2ac3de', light = '#188092' },
  cyan3    = { dark = '#7dcfff', light = '#007197' },
  cyan4    = { dark = '#89ddff', light = '#006a83' },

  teal1    = { dark = '#243e4a', light = '#b7ced5' },
  teal2    = { dark = '#449dab', light = '#4197a4' },
  teal3    = { dark = '#1abc9c', light = '#118c74' },

  green    = { dark = '#9ece6a', light = '#587539' },

  yellow   = { dark = '#e0af68', light = '#8c6c3e' },

  orange   = { dark = '#ff9e64', light = '#b15c00' },

  red1     = { dark = '#4a272f', light = '#dababe' },
  red2     = { dark = '#914c54', light = '#c47981' },
  red3     = { dark = '#db4b4b', light = '#c64343' },

  purple   = { dark = '#bb9af7', light = '#9854f1' },
}

---@generic T extends keyof Palette
---@param name T
---@return Palette[T]['dark' | 'light']
local function color(name)
  return palette[name][mode]
end

local theme = {}

theme.bg = {
  main = color('neutral3'),
  alt  = color('neutral2'),
}

theme.fg = {
  main   = color('muted6'),
  alt    = color('muted5'),
  invert = color('neutral1'),
}

theme.ui = {
  sl_info = color('neutral4'),
  curline = color('neutral5'),
  folded  = color('neutral6'),
  visual  = color('muted1'),
  search  = color('blue1'),
  nontext = color('muted3'),
}

theme.accent = {
  blue    = color('blue3'),
  cyan    = color('cyan1'),
  teal    = color('teal3'),
  green   = color('green'),
  yellow  = color('yellow'),
  orange  = color('orange'),
  red     = color('red3'),
  magenta = color('purple'),
}

theme.syntax = {
  comment  = color('muted4'),
  special  = color('cyan2'),
  preproc  = color('cyan3'),
  operator = color('cyan4'),
}

theme.diff = {
  bg = {
    add    = color('teal1'),
    change = color('neutral4'),
    text   = color('muted2'),
    delete = color('red1'),
  },

  fg = {
    add    = color('teal2'),
    change = color('blue2'),
    delete = color('red2'),
  },
}

theme.diag = {
  error = theme.accent.red,
  warn  = theme.accent.yellow,
  info  = theme.accent.cyan,
  hint  = theme.accent.teal,
}

local hl = {
  Normal = { bg = theme.bg.main, fg = theme.fg.main },
  Visual = { bg = theme.ui.visual },
  Search = { bg = theme.ui.search, fg = theme.fg.main },
  CurSearch = { bg = theme.accent.orange, fg = theme.fg.invert },
  CursorLine = { bg = theme.ui.curline },
  Folded = { bg = theme.ui.folded, fg = theme.accent.blue },
  WinSeparator = { fg = theme.accent.blue },
  MatchParen = { fg = theme.accent.orange, bold = true },
  NonText = { fg = theme.ui.nontext },

  NormalFloat = { bg = theme.bg.alt, fg = theme.fg.main },
  FloatBorder = { link = 'WinSeparator' },
  FloatTitle = { link = 'FloatBorder' },

  Pmenu = { link = 'NormalFloat' },
  PmenuBorder = { link = 'FloatBorder' },
  PmenuThumb = { bg = theme.accent.blue },
  PmenuSel = { link = 'CursorLine' },
  PmenuMatch = { fg = theme.accent.blue, bold = true },

  SignColumn = { link = 'NonText' },
  CursorLineSign = { fg = theme.accent.orange, bold = true },
  LineNr = { link = 'SignColumn' },
  CursorLineNr = { link = 'CursorLineSign' },
  CursorLineFold = { link = 'CursorLineSign' },

  StatusLine = { bg = theme.bg.alt, fg = theme.fg.alt },
  StatusLineNC = { bg = theme.bg.alt, fg = theme.ui.nontext },
  StatusLineInfo = { bg = theme.ui.sl_info, fg = theme.fg.alt },
  StatusLineDiagnosticError = { bg = theme.ui.sl_info, fg = theme.diag.error },
  StatusLineDiagnosticWarn = { bg = theme.ui.sl_info, fg = theme.diag.warn },
  StatusLineDiagnosticInfo = { bg = theme.ui.sl_info, fg = theme.diag.info },
  StatusLineDiagnosticHint = { bg = theme.ui.sl_info, fg = theme.diag.hint },
  StatusLineModeNormal = { bg = theme.accent.blue, fg = theme.fg.invert, bold = true },
  StatusLineModeVisual = { bg = theme.accent.magenta, fg = theme.fg.invert, bold = true },
  StatusLineModeInsert = { bg = theme.accent.green, fg = theme.fg.invert, bold = true },
  StatusLineModeReplace = { bg = theme.accent.red, fg = theme.fg.invert, bold = true },
  StatusLineModeCommand = { bg = theme.accent.yellow, fg = theme.fg.invert, bold = true },
  StatusLineModeOther = { bg = theme.accent.teal, fg = theme.fg.invert, bold = true },

  TabLineSel = { bg = theme.accent.blue, fg = theme.fg.invert, bold = true },

  DiagnosticError = { fg = theme.diag.error },
  DiagnosticWarn = { fg = theme.diag.warn },
  DiagnosticInfo = { fg = theme.diag.info },
  DiagnosticHint = { fg = theme.diag.hint },
  DiagnosticUnderlineError = { sp = theme.diag.error, underline = true },
  DiagnosticUnderlineWarn = { sp = theme.diag.warn, underline = true },
  DiagnosticUnderlineInfo = { sp = theme.diag.info, underline = true },
  DiagnosticUnderlineHint = { sp = theme.diag.hint, underline = true },

  QuickFixLine = { bg = theme.ui.visual, bold = true },
  Error = { link = 'DiagnosticError' },

  MsgArea = { fg = theme.fg.alt },
  ModeMsg = { fg = theme.fg.alt, bold = true },
  ErrorMsg = { link = 'DiagnosticError' },
  WarningMsg = { link = 'DiagnosticWarn' },
  OkMsg = { link = 'DiagnosticHint' },
  MoreMsg = { fg = theme.accent.blue },
  Title = { fg = theme.accent.blue, bold = true },
  Question = { link = 'MoreMsg' },

  DiffAdd = { bg = theme.diff.bg.add },
  DiffChange = { bg = theme.diff.bg.change },
  DiffDelete = { bg = theme.diff.bg.delete },
  DiffText = { bg = theme.diff.bg.text },
  Added = { fg = theme.diff.fg.add },
  Changed = { fg = theme.diff.fg.change },
  Removed = { fg = theme.diff.fg.delete },

  Comment = { fg = theme.syntax.comment },
  Constant = { fg = theme.accent.orange },
  Delimiter = { fg = theme.fg.alt },
  Directory = { fg = theme.accent.blue },
  Function = { fg = theme.accent.blue },
  Identifier = { fg = theme.fg.main },
  Operator = { fg = theme.syntax.operator },
  PreProc = { fg = theme.syntax.preproc },
  Special = { fg = theme.syntax.special },
  Statement = { fg = theme.accent.magenta },
  String = { fg = theme.accent.green },
  Type = { link = 'Special' },
  ['@constructor'] = { link = 'Delimiter' },
  ['@variable'] = { link = 'Identifier' },

  netrwTreeBar = { link = 'NonText' },
}

for name, config in pairs(hl) do
  vim.api.nvim_set_hl(0, name, config)
end
