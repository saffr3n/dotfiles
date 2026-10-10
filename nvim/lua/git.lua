local utils        = require('utils')
local meanwhile    = require('meanwhile')
local Promise      = meanwhile.Promise
local promisify    = meanwhile.promisify
local async, await = meanwhile.async, meanwhile.await

local fn  = vim.fn
local uv  = vim.uv
local api = vim.api

if fn.executable('git') == 0 then return end

---@type {
---  gen        : integer,
---  cwd?       : string,
---  dir?       : string,
---  root?      : string,
---  branch?    : string,
---  head?      : string,
---  index?     : string,
---  [integer]? : { path: string },
---}
local state = { gen = 0 }

---@type uv.uv_fs_event_t?
local watcher

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

---@param path  string
---@param flags string | integer
---@param mode  integer
---@param cb    fun(err?: string, fd?: integer)
local fs_open = promisify(function(path, flags, mode, cb)
  uv.fs_open(path, flags, mode, function(err, fd)
    if err then
      cb(err)
    else
      cb(nil, fd)
    end
  end)
end)

---@param fd integer
---@param cb fun(err?: string, stat?: uv.fs_stat.result)
local fs_stat = promisify(function(fd, cb)
  uv.fs_fstat(fd, function(err, stat)
    if err then
      cb(err)
    else
      cb(nil, stat)
    end
  end)
end)

---@param fd     integer
---@param size   integer
---@param offset integer
---@param cb     fun(err?: string, data?: string)
local fs_read = promisify(function(fd, size, offset, cb)
  uv.fs_read(fd, size, offset, function(err, data)
    if err then
      cb(err)
    else
      cb(nil, data)
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
  if gen ~= state.gen then return end
  if err then return error(err) end

  if dir ~= state.dir then
    notify('SaffGitDirChanged', { old = state.dir, new = dir })
    state.dir = dir
  end

  return dir
end)

---@param gen integer
local update_root = async(function(gen)
  local root, err = await(syscall({ 'git', 'rev-parse', '--show-toplevel' }))
  if gen ~= state.gen then return end
  if err then return error(err) end

  if root ~= state.root then
    notify('SaffGitRootChanged', { old = state.root, new = root })
    state.root = root
  end

  return root
end)

---@param gen integer
local update_branch = async(function(gen)
  local branch, err = await(syscall({ 'git', 'symbolic-ref', '--short', 'HEAD' }))
  if gen ~= state.gen then return end
  if err then
    branch, err = await(syscall({ 'git', 'rev-parse', '--short', 'HEAD' }))
    if gen ~= state.gen then return end
    if err then return error(err) end
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
  if gen ~= state.gen then return end
  if err then return error(err) end

  if head ~= state.head then
    update_branch(gen)
    notify('SaffGitHeadChanged', { old = state.head, new = head })
    state.head = head
  end

  return head
end)

---@param gen integer
local update_index = async(function(gen)
  local path, err_path = await(syscall({ 'git', 'rev-parse', '--git-path', 'index' }))
  if gen ~= state.gen then return end
  if err_path then return error(err_path) end ---@cast path -?
  path = fn.fnamemodify(path, ':p')

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
  if gen ~= state.gen then
    uv.fs_close(fd)
    return
  end
  if err_data then
    uv.fs_close(fd)
    return error(err_data)
  end ---@cast data -?

  uv.fs_close(fd)

  local index = fn.sha256(data)
  if index ~= state.index then
    notify('SaffGitIndexChanged', { old = state.index, new = index })
    state.index = index
  end

  return index
end)

---@param err string?
local function on_dir_changed(err)
  if err then return error(err) end
  update_head(state.gen)
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

---@param buf integer
local function get_buf_path(buf)
  local bo = vim.bo[buf]
  if not state.root
    or not api.nvim_buf_is_valid(buf)
    or not bo.modifiable
    or bo.buftype ~= ''
  then return nil end

  local name = api.nvim_buf_get_name(buf)
  if name == '' then return nil end
  return vim.fs.relpath(state.root, name)
end

---@param buf integer
local function clear_buf(buf)
  state[buf] = nil
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

---@param buf integer
local function init_buf(buf)
  local path = get_buf_path(buf)
  if not path then return clear_buf(buf) end

  local s = state[buf]
  if not s then
    state[buf] = { path = path }
    s          = state[buf]
  elseif path ~= s.path then
    s.path = path
  end
end

local init = async(function()
  local cwd = uv.cwd()
  if not cwd then return clear() end

  local gen   = state.gen
  local tasks = {}

  if cwd ~= state.cwd then
    gen       = gen + 1
    state.gen = gen
    state.cwd = cwd

    if not await(update_dir(gen)) then return clear() end
    start_watcher()
    table.insert(tasks, update_root(gen))
  end

  table.insert(tasks, update_head(gen))
  table.insert(tasks, update_index(gen))
  await(Promise.all(tasks))

  utils.for_visible_bufs(function(buf) init_buf(buf) end)
end)

api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  group    = api.nvim_create_augroup('saff.git', { clear = true }),
  callback = init,
})
