local b   = vim.b
local fn  = vim.fn
local api = vim.api
local au  = api.nvim_create_autocmd

---@type table<integer, {
---  unit      : string,
---  sw        : integer,
---  tick      : integer,
---  [integer] : integer?,
---}?>
local state = {}
local group = api.nvim_create_augroup('saff.indent', { clear = true })
local ns    = api.nvim_create_namespace('saff.indent')

---@param buf integer
local function init(buf)
  local bo = vim.bo[buf]

  if api.nvim_buf_get_name(buf) == ''
    or bo.buftype ~= ''
    or not bo.modifiable
  then return end

  local sw = bo.shiftwidth
  if sw == 0 then sw = bo.tabstop end

  local s = state[buf]
  if not s or s.sw ~= sw then
    state[buf] = {
      unit = '|' .. string.rep(' ', sw - 1),
      sw   = sw,
      tick = b[buf].changedtick,
    }
  end
end

---@param buf integer
local function clear(buf)
  state[buf] = nil
  if not api.nvim_buf_is_valid(buf) then return end
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

---@param win integer
---@param buf integer
---@param top integer
---@param bot integer
local function render(win, buf, top, bot)
  local s = state[buf]
  if not s then return end

  api.nvim_win_call(win, function()
    for i = top, bot do
      if not s[i] then
        local ref = fn.prevnonblank(i)
        if ref == 0 then
          ref = 1
        end
        local ind = fn.indent(ref)

        if i ~= ref then
          ref = fn.nextnonblank(i)
          if ref == 0 then
            ref = api.nvim_buf_line_count(buf)
          end
          ind = math.min(ind, fn.indent(ref))
        end

        local lvl = math.floor(ind / s.sw)
        s[i]      = lvl

        api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
          id                         = i,
          virt_text                  = { { string.rep(s.unit, lvl), 'NonText' } },
          virt_text_win_col          = 0,
          virt_text_repeat_linebreak = true,
          hl_mode                    = 'combine',
        })
      end
    end
  end)
end

au('BufWinEnter', {
  group    = group,
  callback = function(e)
    init(e.buf)
  end,
})

au('BufWipeout', {
  group    = group,
  callback = function(e)
    clear(e.buf)
  end,
})

api.nvim_set_decoration_provider(ns, {
  on_win = function(_, win, buf, top, bot)
    local s = state[buf]
    if not s then return end

    if s.tick ~= b[buf].changedtick then
      clear(buf)
      init(buf)
    end

    render(win, buf, top + 1, bot + 1)
  end,
})
