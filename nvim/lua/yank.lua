local api = vim.api

---@type [integer, integer]?
local cursor

vim.keymap.set({ 'n', 'x' }, 'y', function()
  cursor = api.nvim_win_get_cursor(0)
  return 'y'
end, { expr = true })

api.nvim_create_autocmd('TextYankPost', {
  group    = api.nvim_create_augroup('saff.yank', { clear = true }),
  callback = function()
    vim.hl.hl_op()
    if not cursor then return end
    api.nvim_win_set_cursor(0, cursor)
    cursor = nil
  end,
})
