local palette = {
  black1 = '#16161e',
  black2 = '#1a1b26',

  blue6 = '#565f89',

  cyan1 = '#0db9d7',

  green2 = '#1abc9c',

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
  orange = '#ff9e64',

  diag = {
    error = palette.red3,
    warn = palette.yellow,
    info = palette.cyan1,
    hint = palette.green2,
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
}

for name, config in pairs(hl) do
  vim.api.nvim_set_hl(0, name, config)
end
