local M = {}

---@param keycode string
---@return string
function M.replace_keycode(keycode)
  return vim.api.nvim_replace_termcodes(keycode, true, false, true)
end

return M
