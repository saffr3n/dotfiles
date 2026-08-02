vim.cmd.highlight('clear')
if vim.fn.exists('syntax_on') then
  vim.cmd.syntax('reset')
end

local palette = {
  black1 = '#16161e',
  black2 = '#1a1b26',
  black3 = '#1f2231',

  blue4 = '#394b70',
  blue6 = '#565f89',

  cyan1 = '#0db9d7',

  green1 = '#243e4a',
  green2 = '#449dab',
  green3 = '#1abc9c',

  yellow = '#e0af68',

  red3 = '#db4b4b',

  white1 = '#a9b1d6',
  white2 = '#c0caf5',
}

local theme = {
  bg = {
    main = palette.black2,
    alt = palette.black1,
  },

  fg = {
    main = palette.white2,
    alt = palette.white1,
    dim = palette.blue6 ,
    inverse = palette.black1,
  },

  over1 = '#292e42', -- CursorLine
  over2 = '#283457', -- Visual / QuickFixLine
  over3 = '#3b4261', -- Folded
  over4 = '#3d59a1', -- Search

  blue = '#7aa2f7',
  cyan = '#2ac3de',
  green = '#9ece6a',
  orange = '#ff9e64',
  sky = '#89ddff',
  violet = '#bb9af7',

  diag = {
    error = palette.red3,
    warn = palette.yellow,
    info = palette.cyan1,
    hint = palette.green3,
  },

  diff = {
    add_bg = palette.green1,
    add_fg = palette.green2,
    change_bg = palette.black3,
    text_bg = palette.blue4,
    change_fg = '#6183bb',
    delete_bg = '#4a272f',
    delete_fg = '#914c54',
  },
}

local hl = {
  Normal = { bg = theme.bg.main, fg = theme.fg.main },
  Visual = { bg = theme.over2 },
  Search = { bg = theme.over4, fg = theme.fg.main },
  CurSearch = { bg = theme.orange, fg = theme.fg.inverse },
  CursorLine = { bg = theme.over1 },
  Folded = { bg = theme.over3, fg = theme.blue },
  WinSeparator = { fg = theme.blue },
  MatchParen = { fg = theme.orange, bold = true },
  NonText = { fg = theme.fg.dim },

  NormalFloat = { bg = theme.bg.alt, fg = theme.fg.main },
  FloatBorder = { link = 'WinSeparator' },
  FloatTitle = { link = 'FloatBorder' },

  Pmenu = { link = 'NormalFloat' },
  PmenuBorder = { link = 'FloatBorder' },
  PmenuThumb = { bg = theme.blue },
  PmenuSel = { link = 'CursorLine' },
  PmenuMatch = { fg = theme.blue, bold = true },

  SignColumn = { link = 'NonText' },
  CursorLineSign = { fg = theme.orange, bold = true },
  LineNr = { link = 'SignColumn' },
  CursorLineNr = { link = 'CursorLineSign' },
  CursorLineFold = { link = 'CursorLineSign' },

  StatusLine = { bg = theme.bg.alt, fg = theme.fg.alt },
  StatusLineNC = { bg = theme.bg.alt, fg = theme.fg.dim },

  TabLineSel = { bg = theme.blue, fg = theme.fg.inverse, bold = true },

  DiagnosticError = { fg = theme.diag.error },
  DiagnosticWarn = { fg = theme.diag.warn },
  DiagnosticInfo = { fg = theme.diag.info },
  DiagnosticHint = { fg = theme.diag.hint },
  DiagnosticUnderlineError = { sp = theme.diag.error, underline = true },
  DiagnosticUnderlineWarn = { sp = theme.diag.warn, underline = true },
  DiagnosticUnderlineInfo = { sp = theme.diag.info, underline = true },
  DiagnosticUnderlineHint = { sp = theme.diag.hint, underline = true },

  QuickFixLine = { bg = theme.over2, bold = true },
  Error = { link = 'DiagnosticError' },

  MsgArea = { fg = theme.fg.alt },
  ModeMsg = { fg = theme.fg.alt, bold = true },
  ErrorMsg = { link = 'DiagnosticError' },
  WarningMsg = { link = 'DiagnosticWarn' },
  OkMsg = { link = 'DiagnosticHint' },
  MoreMsg = { fg = theme.blue },
  Title = { fg = theme.blue, bold = true },
  Question = { link = 'MoreMsg' },

  DiffAdd = { bg = theme.diff.add_bg },
  DiffChange = { bg = theme.diff.change_bg },
  DiffDelete = { bg = theme.diff.delete_bg },
  DiffText = { bg = theme.diff.text_bg },
  Added = { fg = theme.diff.add_fg },
  Changed = { fg = theme.diff.change_fg },
  Removed = { fg = theme.diff.delete_fg },

  Comment = { link = 'NonText' },
  Constant = { fg = theme.orange },
  Delimiter = { fg = theme.fg.alt },
  Directory = { fg = theme.blue },
  Function = { fg = theme.blue },
  Identifier = { fg = theme.fg.main },
  Operator = { fg = theme.sky },
  PreProc = { fg = theme.sky },
  Special = { fg = theme.cyan },
  Statement = { fg = theme.violet },
  String = { fg = theme.green },
  Type = { fg = theme.cyan },
  ['@constructor'] = { link = 'Delimiter' },
  ['@variable'] = { link = 'Identifier' },

  netrwTreeBar = { link = 'NonText' },
}

for name, config in pairs(hl) do
  vim.api.nvim_set_hl(0, name, config)
end
