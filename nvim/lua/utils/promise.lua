local M = {}
local H = {}

local Proto = {}

function M.new(executor)
  local self = setmetatable({
    status = 'pending',
    value = nil,
    reactions = {},
  }, Proto)

  if executor then
    local resolve = function(value) H.resolve(self, value) end
    local reject = function(cause) H.reject(self, cause) end
    local ok, err = H.try(executor, resolve, reject)
    if not ok then reject(err) end
  end

  return self
end

function H.resolve(promise, value) H.settle(promise, 'resolved', value) end
function H.reject(promise, cause) H.settle(promise, 'rejected', cause) end

function H.settle(promise, status, value)
  if promise.status ~= 'pending' then return end
  promise.status = status
  promise.value = value
end

function H.try(fn, ...)
  return xpcall(fn, function(err) return debug.traceback(err, 2) end, ...)
end

function Proto:wait(on_resolved)
  local next = M.new()
  local reaction = { on_resolved = on_resolved, next = next }
  table.insert(self.reactions, reaction)
  return next
end

return M
