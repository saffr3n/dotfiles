if vim.fn.executable('git') == 0 then return end

local meanwhile    = require('meanwhile')
local promisify    = meanwhile.promisify
local async, await = meanwhile.async, meanwhile.await

local g    = vim.g
local trim = vim.trim
local api  = vim.api

---@type { cwd?: string }
local state = {}

---@param cmd string[]
---@param cb  fun(err?: string, out?: string)
local syscall = promisify(function(cmd, cb)
  local trace = debug.traceback('', 6)

  vim.system(cmd, function(out)
    if out.code ~= 0 then
      cb(out.stderr .. trace)
    else
      cb(nil, out.stdout)
    end
  end)
end)

---@param msg string
local function error(msg)
  vim.notify(msg, vim.log.levels.ERROR)
end

local update_dir = async(function()
  local dir, err = await(syscall({ 'git', 'rev-parse', '--git-dir' }))
  if err then
    return error(err)
  end

  dir = trim(dir--[[@cast -?]])
  if dir == '' then
    dir = nil
  end

  g.git_dir = dir
end)

local update_root = async(function()
  local root, err = await(syscall({ 'git', 'rev-parse', '--show-toplevel' }))
  if err then
    return error(err)
  end

  root = trim(root--[[@cast -?]])
  if root == '' then
    root = nil
  end

  g.git_root = root
end)

local update_head = async(function()
  local head, err = await(syscall({ 'git', 'rev-parse', 'HEAD' }))
  if err then
    return error(err)
  end

  head = trim(head--[[@cast -?]])
  if head == '' then
    head = nil
  end

  g.git_head = head
end)

api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  group    = api.nvim_create_augroup('saff.git', { clear = true }),
  callback = async(function()
    local cwd = vim.uv.cwd()
    if not cwd then return end

    if cwd ~= state.cwd then
      state.cwd = cwd
      await(update_dir())
      if not vim.g.git_dir then return end
      update_root(state_gen)
    end

    update_head(state_gen)
  end),
})
