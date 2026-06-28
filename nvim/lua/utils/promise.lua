local M = {}
local H = {}

local Proto = {}

H.state = setmetatable({}, { __mode = 'k' })

H.meta = {
  __index = function(self, key)
    if key == 'status' then return H.state[self][key] end
    return Proto[key]
  end,
  __newindex = function(_, key)
    if key == 'status' then
      vim.notify(debug.traceback("TypeError: Cannot assign to read-only property 'status'", 2), vim.log.levels.ERROR)
    end
  end,
}

function M.new(executor)
  local self = setmetatable({}, H.meta)

  H.state[self] = {
    status = 'pending',
    value = nil,
    reactions = {},
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
  local state = H.state[promise]
  if state.status ~= 'pending' then return end
  state.status = status
  state.value = value
  H.dispatch(promise)
end

function H.dispatch(promise)
  local state = H.state[promise]
  for _, reaction in ipairs(state.reactions) do
    H.handle(promise, reaction)
  end
  state.reactions = {}
end

function H.handle(promise, reaction)
  vim.schedule(function()
    local state = H.state[promise]

    local cb
    if state.status == 'resolved' then
      cb = reaction.on_resolved
    elseif state.status == 'rejected' then
      cb = reaction.on_rejected
    end

    if cb then
      local ok, res = H.try(cb, state.value)
      if ok then
        H.resolve(reaction.next, res)
      else
        H.reject(reaction.next, res)
      end
      return
    end

    cb = reaction.on_settled
    if cb then
      local ok, err = H.try(cb)
      if not ok then return H.reject(reaction.next, err) end
    end

    if state.status == 'resolved' then
      H.resolve(reaction.next, state.value)
    else
      H.reject(reaction.next, state.value)
    end
  end)
end

function H.try(fn, ...)
  return xpcall(fn, function(err) return debug.traceback(err, 2) end, ...)
end

function Proto:wait(on_resolved) return H.new_link(self, { on_resolved = on_resolved }) end
function Proto:catch(on_rejected) return H.new_link(self, { on_rejected = on_rejected }) end
function Proto:finally(on_settled) return H.new_link(self, { on_settled = on_settled }) end

function H.new_link(promise, handler)
  local state = H.state[promise]
  local next = M.new()
  local reaction = vim.tbl_extend('force', handler, { next = next })
  if state.status == 'pending' then
    table.insert(state.reactions, reaction)
  else
    H.handle(promise, reaction)
  end
  return next
end

return M
