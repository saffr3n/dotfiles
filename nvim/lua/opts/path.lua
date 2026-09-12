local meanwhile    = require('meanwhile')
local promisify    = meanwhile.promisify
local async, await = meanwhile.async, meanwhile.await

local o   = vim.o
local uv  = vim.uv
local api = vim.api

local TIMEOUT = 300
local EXCLUDE = {
  ['.git']     = true,
  node_modules = true,
}

local gen     = 0
local default = o.path

---@param path string
---@param cb   fun(err?: string, dir?: uv.luv_dir_t)
local opendir = promisify(function(path, cb)
  uv.fs_opendir(path, cb)
end)

---@param dir uv.luv_dir_t
---@param cb  fun(err?: string, entries?: table<integer, { name: string, type: string }>)
local readdir = promisify(function(dir, cb)
  uv.fs_readdir(dir, cb)
end)

---@param dirs uv.luv_dir_t[]
local function clean(dirs)
  for _, dir in ipairs(dirs) do
    dir:closedir()
  end
end

---@param dirs uv.luv_dir_t[]
local function cancel(dirs)
  clean(dirs)
  vim.schedule(function()
    vim.notify("'path' generation timed out, using default", vim.log.levels.WARN)
  end)
end

---@param deadline number
local function should_cancel(deadline)
  return uv.hrtime() > deadline
end

api.nvim_create_autocmd({ 'VimEnter', 'DirChanged' }, {
  group    = api.nvim_create_augroup('saff.path', { clear = true }),
  callback = async(function()
    local cwd = uv.cwd()
    if not cwd then return end

    gen            = gen + 1
    local this_gen = gen
    local queue    = { cwd }
    local dirs     = {}
    local res      = {}
    local deadline = uv.hrtime() + TIMEOUT * 1e6

    while #queue > 0 do
      local dirname = table.remove(queue)
      local dir     = await(opendir(dirname))

      if dir then
        table.insert(dirs, dir)
        if should_cancel(deadline) then
          return cancel(dirs)
        end

        while true do
          local entries = await(readdir(dir))
          if should_cancel(deadline) then
            return cancel(dirs)
          end
          if not entries then break end

          for _, entry in ipairs(entries) do
            if entry.type == 'directory' and not EXCLUDE[entry.name] then
              local full = vim.fs.joinpath(dirname, entry.name)
              table.insert(queue, full)
              table.insert(res, full)
            end
          end
        end
      end
    end

    clean(dirs)
    if this_gen ~= gen then return end
    o.path = default .. table.concat(res, ',')
  end),
})
