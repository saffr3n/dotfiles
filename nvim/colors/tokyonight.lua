local palette = {
  black1 = '#16161e',
  black2 = '#1a1b26',
  blue6 = '#565f89',
  white2 = '#c0caf5',
}

local theme = {
  bg = {
    main = palette.black2,
  },

  fg = {
    main = palette.white2,
    dim = palette.blue6 ,
    inverse = palette.black1,
  },

  over1 = '#292e42', -- CursorLine
  over2 = '#283457', -- Visual / QuickFixLine
  over3 = '#3b4261', -- Folded
  over4 = '#3d59a1', -- Search

  blue = '#7aa2f7',
  orange = '#ff9e64',
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
}

for name, config in pairs(hl) do
  vim.api.nvim_set_hl(0, name, config)
end
