if vim.fn.executable('git') == 0 then return end

local meanwhile    = require('meanwhile')
local promisify    = meanwhile.promisify
local async, await = meanwhile.async, meanwhile.await

local api = vim.api

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

local update_dir = async(function()
  local dir, err = await(syscall({ 'git', 'rev-parse', '--git-dir' }))
  if err then
    return vim.notify(err, vim.log.levels.ERROR)
  end

  dir = vim.trim(dir--[[@cast -?]])
  if dir == '' then
    dir = nil
  end

  vim.g.git_dir = dir
end)

api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  group    = api.nvim_create_augroup('saff.git', { clear = true }),
  callback = async(function()
    local cwd = vim.uv.cwd()
    if not cwd then return end

    if cwd ~= state.cwd then
      state.cwd = cwd
      await(update_dir())
    end
  end),
})
