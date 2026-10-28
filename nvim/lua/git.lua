local meanwhile    = require('meanwhile')
local promisify    = meanwhile.promisify
local async, await = meanwhile.async, meanwhile.await

local fn  = vim.fn
local api = vim.api
local uv  = vim.uv

if fn.executable('git') == 0 then return end

---@type {
---  gen     : integer,
---  cwd?    : string,
---  dir?    : string,
---  root?   : string,
---  branch? : string,
---  head?   : string,
---  index?  : string,
---}
local state = { gen = 0 }

---@type uv.uv_fs_event_t?
local watcher

---@param event
---| 'SaffGitDirChanged'
---| 'SaffGitRootChanged'
---| 'SaffGitIndexChanged'
---| 'SaffGitHeadChanged'
---| 'SaffGitBranchChanged'
---@param data { old?: string, new?: string }
local function notify(event, data)
  api.nvim_exec_autocmds('User', { pattern = event, data = data })
end

---@param cmd string[]
---@param cb  fun(err?: string, out?: string)
local syscall = promisify(function(cmd, cb)
  local trace = debug.traceback('', 6)
  vim.system(cmd, function(out)
    if out.code ~= 0
      then cb(out.stderr .. trace, nil)
      else cb(nil, out.stdout)
    end
  end)
end)

---@param path string
---@param cb   fun(err?: string, fd?: integer)
local fs_open = promisify(function(path, cb)
  uv.fs_open(path, 'r', 0, function(err, fd)
    if err
      then cb(err, nil)
      else cb(nil, fd)
    end
  end)
end)

---@param fd integer
---@param cb fun(err?: string, stat?: uv.fs_stat.result)
local fs_stat = promisify(function(fd, cb)
  uv.fs_fstat(fd, function(err, stat)
    if err
      then cb(err, nil)
      else cb(nil, stat)
    end
  end)
end)

---@param fd   integer
---@param size integer
---@param cb   fun(err?: string, data?: string)
local fs_read = promisify(function(fd, size, cb)
  uv.fs_read(fd, size, 0, function(err, data)
    if err
      then cb(err, nil)
      else cb(nil, data)
    end
  end)
end)

---@param msg string
local function error(msg)
  vim.notify(msg, vim.log.levels.ERROR)
end

---@param gen integer
---@return string?
local update_dir = async(function(gen)
  local dir, err = await(syscall({ 'git', 'rev-parse', '--git-dir' }))
  if gen ~= state.gen then return end
  if err then return error(err) end ---@cast dir -?
  dir = vim.trim(dir)

  if dir ~= state.dir then
    notify('SaffGitDirChanged', { old = state.dir, new = dir })
    state.dir = dir
  end

  return dir
end)

---@param gen integer
---@return string?
local update_root = async(function(gen)
  local root, err = await(syscall({ 'git', 'rev-parse', '--show-toplevel' }))
  if gen ~= state.gen then return end
  if err then return error(err) end ---@cast root -?
  root = vim.trim(root)

  if root ~= state.root then
    notify('SaffGitRootChanged', { old = state.root, new = root })
    state.root = root
  end

  return root
end)

---@param gen integer
---@return string?
local update_index = async(function(gen)
  local path, err_path = await(syscall({ 'git', 'rev-parse', '--git-path', 'index' }))
  if gen ~= state.gen then return end
  if err_path then return error(err_path) end ---@cast path -?
  path = fn.fnamemodify(vim.trim(path), ':p')

  local fd, err_fd = await(fs_open(path, 'r', 0))
  if gen ~= state.gen then return end
  if err_fd then return error(err_fd) end ---@cast fd -?

  local stat, err_stat = await(fs_stat(fd))
  if gen ~= state.gen then
    uv.fs_close(fd)
    return
  end
  if err_stat then
    uv.fs_close(fd)
    return error(err_stat)
  end ---@cast stat -?

  local data, err_data = await(fs_read(fd, stat.size, 0))
  uv.fs_close(fd)
  if gen ~= state.gen then return end
  if err_data then return error(err_data) end ---@cast data -?

  local index = fn.sha256(data)
  if index ~= state.index then
    notify('SaffGitIndexChanged', { old = state.index, new = index })
    state.index = index
  end

  return index
end)

---@param gen integer
---@return string?
local update_head = async(function(gen)
  local head, err = await(syscall({ 'git', 'rev-parse', 'HEAD' }))
  if gen ~= state.gen then return end
  if err then return error(err) end ---@cast head -?
  head = vim.trim(head)

  if head ~= state.head then
    notify('SaffGitHeadChanged', { old = state.head, new = head })
    state.head = head
  end

  return head
end)

---@param gen integer
---@return string?
local update_branch = async(function(gen)
  local branch, err = await(syscall({ 'git', 'symbolic-ref', '--short', 'HEAD' }))
  if gen ~= state.gen then return end
  if err then
    branch, err = await(syscall({ 'git', 'rev-parse', '--short', 'HEAD' }))
    if gen ~= state.gen then return end
    if err then return error(err) end
  end ---@cast branch -?
  branch = vim.trim(branch)

  if branch ~= state.branch then
    notify('SaffGitBranchChanged', { old = state.branch, new = branch })
    state.branch = branch
  end

  return branch
end)

---@param err string?
local function on_dir_changed(err)
  if err then return error(err) end
  update_head(state.gen)
  update_branch(state.gen)
  update_index(state.gen)
end

local function stop_watcher()
  if not watcher then return end
  if not watcher:is_closing() then watcher:close() end
  watcher = nil
end

local function start_watcher()
  stop_watcher()

  local dir = state.dir
  if not dir then return end

  watcher = uv.new_fs_event()
  if not watcher then return end
  watcher:start(dir, {}, on_dir_changed)
end

local function clear()
  stop_watcher()

  if state.dir    then notify('SaffGitDirChanged',    { old = state.dir,    new = nil }) end
  if state.root   then notify('SaffGitRootChanged',   { old = state.root,   new = nil }) end
  if state.branch then notify('SaffGitBranchChanged', { old = state.branch, new = nil }) end
  if state.head   then notify('SaffGitHeadChanged',   { old = state.head,   new = nil }) end
  if state.index  then notify('SaffGitIndexChanged',  { old = state.index,  new = nil }) end

  state = { gen = state.gen + 1 }
end

local init = async(function()
  local cwd = uv.cwd()
  if not cwd then return clear() end

  local gen   = state.gen

  if cwd ~= state.cwd then
    gen       = gen + 1
    state.gen = gen
    state.cwd = cwd

    local dir = await(update_dir(gen))
    if not dir then return clear() end

    start_watcher()
    update_root(gen)
  end

  update_index(gen)
  update_head(gen)
  update_branch(gen)
end)

api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  group    = api.nvim_create_augroup('saff.git', { clear = true }),
  callback = init,
})
