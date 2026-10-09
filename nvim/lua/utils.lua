local M = {}

---@param cb fun(buf: integer, win, integer)
function M.for_visible_bufs(cb)
  local seen = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not seen[buf] then
      seen[buf] = true
      cb(buf, win)
    end
  end
end

return M
