local M = {}

---@type 'dark' | 'light'
local _mode

---@class (private) Colors
local colors = {
  primary   = { dark = '#7aa2f7', light = '#2e7de9' },
  surface   = { dark = '#1a1b26', light = '#e1e2e7' },
  secondary = { dark = '#bb9af7', light = '#9854f1' },
  error     = { dark = '#f7768e', light = '#f52a65' },
}

---@param name keyof Colors
local function color(name)
  return colors[name][_mode]
end

---@param mode 'dark' | 'light'
M.apply = function(mode)
  _mode = mode
  hl.config({
    general = {
      col = {
        active_border = color('primary'),
        inactive_border = color('surface'),
      },
    },

    group = {
      col = {
        border_active = color('secondary'),
        border_inactive = color('surface'),
        border_locked_active = color('error'),
        border_locked_inactive = color('surface'),
      },

      groupbar = {
        col = {
          active = color('secondary'),
          inactive = color('surface'),
          locked_active = color('error'),
          locked_inactive = color('surface'),
        },
      },
    },

    decoration = { shadow = { color = color('surface') .. '99' } },
    misc = { background_color = color('surface') },
  })
end

return M
