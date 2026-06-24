local M = {}

function M.new()
  local self = {
    status = 'pending',
    value = nil,
  }

  return self
end

return M
