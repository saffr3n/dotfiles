---@alias Awaited<T> T extends Promise<infer U> and U or T

---@alias AsyncResultCallback<T> fun(error?: any, value?: T): any

---@alias Promise.Status 'pending' | 'resolved' | 'rejected'

---@alias Promise.Handler.Resolved<T, U> fun(value: T): U

---@alias Promise.Handler.Rejected<U> fun(cause: any): U

---@alias Promise.Handler.Settled fun()

---@alias Promise.Handler<T, U> Promise.Handler.Resolved<T, U> | Promise.Handler.Rejected<U> | Promise.Handler.Settled

---@class (private) Promise.Reaction.Handler.Resolved
---@field on_resolved? Promise.Handler.Resolved<any, any>

---@class (private) Promise.Reaction.Handler.Rejected
---@field on_rejected? Promise.Handler.Rejected<any>

---@class (private) Promise.Reaction.Handler.Settled
---@field on_settled? Promise.Handler.Settled

---@alias (private) Promise.Reaction.Handler Promise.Reaction.Handler.Resolved | Promise.Reaction.Handler.Rejected | Promise.Reaction.Handler.Settled

---@class (private) Promise.Reaction : Promise.Reaction.Handler
---@field next Promise<any>

local M = {}
local H = {}

---@class Promise<T>
---@field status Promise.Status `@readonly`
local Proto = {}

---@type table<Promise<any>, { status: Promise.Status, value: any, reactions: Promise.Reaction[] }>
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

---@generic T
---@param executor? fun(resolve: fun(value: T), reject: fun(cause: any))
---@return Promise<T>
function M.new(executor)
  ---@type Promise<any>
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

---@generic T
---@param value T
---@return Promise<Awaited<T>>
function M.resolve(value)
  return M.new(function(resolve) resolve(value) end)
end

---@param cause any
---@return Promise<never>
function M.reject(cause)
  return M.new(function(_, reject) reject(cause) end)
end

---@generic T
---@param promises T
---@return Promise<{ [I in keyof T]: Awaited<T[I]> }>
function M.all(promises)
  return M.new(function(resolve, reject)
    local res = {}
    local remaining = #promises
    if remaining == 0 then return resolve(res) end

    for i, promise in ipairs(promises) do
      promise
        :next(function(val)
          res[i] = val
          remaining = remaining - 1
          if remaining == 0 then resolve(res) end
        end)
        :catch(function(err) reject(err) end)
    end
  end)
end

---@generic T, U
---@param fn fun(...: T..., cb: AsyncResultCallback<U>): any
---@return fun(...: T...): Promise<Awaited<U>>
---@overload fun(fn: fun(cb: AsyncResultCallback<U>): any): fun(): Promise<Awaited<U>>
function M.promisify(fn)
  return function(...)
    local args = { ... }
    return M.new(function(resolve, reject)
      table.insert(args, function(err, val)
        if err then
          reject(err)
        else
          resolve(val)
        end
      end)
      local ok, err = pcall(fn, unpack(args))
      if not ok then reject(err) end
    end)
  end
end

---@param promise Promise<any>
---@param value any
function H.resolve(promise, value)
  if H.is_promise(value) then
    return H.adopt(promise, value)
  end
  H.settle(promise, 'resolved', value)
end

---@param promise Promise<any>
---@param cause any
function H.reject(promise, cause) H.settle(promise, 'rejected', cause) end

---@param promise Promise<any>
---@param status Promise.Status
---@param value any
function H.settle(promise, status, value)
  local state = H.state[promise]
  if state.status ~= 'pending' then return end
  state.status = status
  state.value = value
  H.dispatch(promise)
end

---@param promise Promise<any>
function H.dispatch(promise)
  local state = H.state[promise]
  for _, reaction in ipairs(state.reactions) do
    H.handle(promise, reaction)
  end
  state.reactions = {}
end

---@param promise Promise<any>
---@param reaction Promise.Reaction
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
      local ok, res = H.try(cb)
      if not ok then return H.reject(reaction.next, res) end
      if H.is_promise(res) then
        res:next(function()
          if state.status == 'resolved' then
            H.resolve(reaction.next, state.value)
          else
            H.reject(reaction.next, state.value)
          end
        end):catch(function(cause)
          H.reject(reaction.next, cause)
        end)
        return
      end
    end

    if state.status == 'resolved' then
      H.resolve(reaction.next, state.value)
    else
      H.reject(reaction.next, state.value)
    end
  end)
end

---@generic T, U
---@param fn fun(...: T...): U...
---@param ... T...
---@return boolean, U...
function H.try(fn, ...)
  return xpcall(fn, function(err) return debug.traceback(err, 2) end, ...)
end

---@param value any
---@return_cast value Promise<any>
function H.is_promise(value) return type(value) == 'table' and getmetatable(value) == H.meta end

---@param target Promise<any>
---@param source Promise<any>
function H.adopt(target, source)
  if target == source then return H.reject(target, 'TypeError: Promise resolved with itself') end
  source:next(function(value) H.resolve(target, value) end):catch(function(cause) H.reject(target, cause) end)
end

---@generic U
---@param on_resolved Promise.Handler.Resolved<T, U>
---@return Promise<Awaited<U>>
function Proto:next(on_resolved) return H.new_link(self, { on_resolved = on_resolved }) end

---@generic U
---@param on_rejected Promise.Handler.Rejected<U>
---@return Promise<Awaited<T | U>>
function Proto:catch(on_rejected) return H.new_link(self, { on_rejected = on_rejected }) end

---@param on_settled Promise.Handler.Settled
---@return Promise<Awaited<T>>
function Proto:finally(on_settled) return H.new_link(self, { on_settled = on_settled }) end

---@param promise Promise<any>
---@param handler Promise.Reaction.Handler
function H.new_link(promise, handler)
  local state = H.state[promise]
  local next = M.new()
  ---@type Promise.Reaction
  local reaction = vim.tbl_extend('force', handler, { next = next })
  if state.status == 'pending' then
    table.insert(state.reactions, reaction)
  else
    H.handle(promise, reaction)
  end
  return next
end

return M
