local map = vim.keymap.set
local fn  = vim.fn

map('i', '<C-p>', function()
  return fn.pumvisible() == 0 and '<Up>' or '<C-p>'
end, { expr = true })
map('i', '<C-n>', function()
  return fn.pumvisible() == 0 and '<Down>' or '<C-n>'
end, { expr = true })

map({ 'i', 'c' }, '<C-b>', '<Left>')
map({ 'i', 'c' }, '<C-f>', '<Right>')
map({ 'i', 'c' }, '<M-b>', '<S-Left>')
map({ 'i', 'c' }, '<M-f>', '<S-Right>')
map({ 'i', 'c' }, '<C-a>', '<Home>')
map({ 'i', 'c' }, '<C-e>', function()
  return fn.pumvisible() == 0 and '<End>' or '<C-e>'
end, { expr = true })

map({ 'i', 'c' }, '<C-d>', '<Del>')

map('i', '<M-d>', '<C-o>dw')
map('c', '<M-d>', function()
  local line   = fn.getcmdline()
  local pos    = fn.getcmdpos()
  local before = line:sub(1, pos - 1)
  local after  = line:sub(pos)

  after = after:gsub('^%w+', '', 1)
  after = after:gsub('^%s+', '', 1)

  fn.setcmdline(before .. after, pos)
end)

map('i', '<C-k>', '<C-o>D')
map('c', '<C-k>', function()
  local line = fn.getcmdline()
  local pos  = fn.getcmdpos()

  fn.setcmdline(line:sub(1, pos - 1), pos)
end)
