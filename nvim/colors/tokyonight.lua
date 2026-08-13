vim.cmd.highlight('clear')
if vim.fn.exists('syntax_on') then
  vim.cmd.syntax('reset')
end

vim.g.colors_name = 'tokyonight'

local palette = {
  neutral1 = '#15161e',
  neutral2 = '#16161e',
  neutral3 = '#1a1b26',
  neutral4 = '#1f2231',
  neutral5 = '#292e42',
  neutral6 = '#3b4261',

  muted1   = '#283457',
  muted2   = '#394b70',
  muted3   = '#545c7e',
  muted4   = '#565f89',
  muted5   = '#a9b1d6',
  muted6   = '#c0caf5',

  blue1    = '#3d59a1',
  blue2    = '#6183bb',
  blue3    = '#7aa2f7',

  cyan1    = '#0db9d7',
  cyan2    = '#2ac3de',
  cyan3    = '#7dcfff',
  cyan4    = '#89ddff',

  teal1    = '#243e4a',
  teal2    = '#449dab',
  teal3    = '#1abc9c',

  green    = '#9ece6a',

  yellow   = '#e0af68',

  orange   = '#ff9e64',

  red1     = '#4a272f',
  red2     = '#914c54',
  red3     = '#db4b4b',

  purple   = '#bb9af7',
}

local theme = {}

theme.bg = {
  main = palette.neutral3,
  alt  = palette.neutral2,
}

theme.fg = {
  main   = palette.muted6,
  alt    = palette.muted5,
  invert = palette.neutral1,
}

theme.ui = {
  curline = palette.neutral5,
  folded  = palette.neutral6,
  visual  = palette.muted1,
  search  = palette.blue1,
  nontext = palette.muted3,
}

theme.accent = {
  blue    = palette.blue3,
  cyan    = palette.cyan1,
  teal    = palette.teal3,
  green   = palette.green,
  yellow  = palette.yellow,
  orange  = palette.orange,
  red     = palette.red3,
  magenta = palette.purple,
}

theme.syntax = {
  comment  = palette.muted4,
  special  = palette.cyan2,
  preproc  = palette.cyan3,
  operator = palette.cyan4,
}

theme.diff = {
  bg = {
    add    = palette.teal1,
    change = palette.neutral4,
    text   = palette.muted2,
    delete = palette.red1,
  },

  fg = {
    add    = palette.teal2,
    change = palette.blue2,
    delete = palette.red2,
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
