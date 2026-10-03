if vim.fn.executable('git') == 0 then return end

local meanwhile    = require('meanwhile')
local promisify    = meanwhile.promisify
local async, await = meanwhile.async, meanwhile.await

local uv       = vim.uv
local api      = vim.api

---@type {
---  cwd    : string?,
---  dir    : string?,
---  root   : string?,
---  branch : string?,
---  head   : string?,
---  index  : string?,
---}
local state     = {}
local state_gen = 0

---@type uv.uv_fs_event_t?
local watcher
local watcher_gen = 0

---@param cmd string[]
---@param cb  fun(err?: string, out?: string)
local syscall = promisify(function(cmd, cb)
  local trace = debug.traceback('', 6)

  vim.system(cmd, function(out)
    if out.code ~= 0 then
      cb(out.stderr .. trace)
    else
      local res = vim.trim(out.stdout--[[@cast -?]])
      cb(nil, res == '' and nil or res)
    end
  end)
end)

---@param msg string
local function error(msg)
  vim.notify(msg, vim.log.levels.ERROR)
end

---@param event
---| 'SaffGitDirChanged'
---| 'SaffGitRootChanged'
---| 'SaffGitBranchChanged'
---| 'SaffGitHeadChanged'
---| 'SaffGitIndexChanged'
---@param data { old?: string, new?: string }
local function notify(event, data)
  api.nvim_exec_autocmds('User', { pattern = event, data = data })
end

---@param gen integer
local update_dir = async(function(gen)
  local dir, err = await(syscall({ 'git', 'rev-parse', '--git-dir' }))
  if gen ~= state_gen then return end

  if err then
    return error(err)
  end

  if dir ~= state.dir then
    notify('SaffGitDirChanged', { old = state.dir, new = dir })
    state.dir = dir
  end

  return dir
end)

---@param gen integer
local update_root = async(function(gen)
  local root, err = await(syscall({ 'git', 'rev-parse', '--show-toplevel' }))
  if gen ~= state_gen then return end

  if err then
    return error(err)
  end

  if root ~= state.root then
    notify('SaffGitRootChanged', { old = state.root, new = root })
    state.root = root
  end

  return root
end)

---@param gen integer
local update_branch = async(function(gen)
  local branch, err = await(syscall({ 'git', 'symbolic-ref', '--short', 'HEAD' }))
  if gen ~= state_gen then return end

  if err then
    branch, err = await(syscall({ 'git', 'rev-parse', '--short', 'HEAD' }))
    if gen ~= state_gen then return end

    if err then
      return error(err)
    end
  end

  if branch ~= state.branch then
    notify('SaffGitBranchChanged', { old = state.branch, new = branch })
    state.branch = branch
  end

  return branch
end)

---@param gen integer
local update_head = async(function(gen)
  local head, err = await(syscall({ 'git', 'rev-parse', 'HEAD' }))
  if gen ~= state_gen then return end

  if err then
    return error(err)
  end

  if head ~= state.head then
    update_branch(gen)
    notify('SaffGitHeadChanged', { old = state.head, new = head })
    state.head = head
  end

  return head
end)

---@param gen integer
local update_index = async(function(gen)
  local index, err = await(syscall({ 'git', 'write-tree' }))
  if gen ~= state_gen then return end

  if err then
    return error(err)
  end

  if index ~= state.index then
    notify('SaffGitIndexChanged', { old = state.index, new = index })
    state.index = index
  end

  return index
end)

---@param err string?
local function on_dir_changed(err)
  if err then
    return error(err)
  end

  watcher_gen     = watcher_gen + 1
  local this_wgen = watcher_gen
  local this_sgen = state_gen

  vim.schedule(function()
    if watcher_gen ~= this_wgen then return end
    update_head(this_sgen)
    update_index(this_sgen)
  end)
end

local function stop_watcher()
  if not watcher then return end
  if not watcher:is_closing() then
    watcher:close()
  end
  watcher = nil
end

local function start_watcher()
  stop_watcher()
  if not state.dir then return end
  watcher = uv.new_fs_event()
  if not watcher then return end
  watcher:start(state.dir, {}, on_dir_changed)
end

local function clear()
  state_gen = state_gen + 1
  stop_watcher()

  if state.dir then
    notify('SaffGitDirChanged',    { old = state.dir,    new = nil })
  end
  if state.root then
    notify('SaffGitRootChanged',   { old = state.root,   new = nil })
  end
  if state.branch then
    notify('SaffGitBranchChanged', { old = state.branch, new = nil })
  end
  if state.head then
    notify('SaffGitHeadChanged',   { old = state.head,   new = nil })
  end
  if state.index then
    notify('SaffGitIndexChanged',  { old = state.index,  new = nil })
  end

  state = {}
end

local init = async(function()
  local cwd = uv.cwd()
  if not cwd then
    return clear()
  end

  if cwd ~= state.cwd then
    state_gen = state_gen + 1
    state.cwd = cwd

    if not await(update_dir(state_gen)) then
      return clear()
    end

    start_watcher()
    update_root(state_gen)
  end

  update_head(state_gen)
  update_index(state_gen)
end)

api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  group    = api.nvim_create_augroup('saff.git', { clear = true }),
  callback = init,
})
