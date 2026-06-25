local M = {}
local H = {}

function M.new(executor)
  local self = {
    status = 'pending',
    value = nil,
  }

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

return M
