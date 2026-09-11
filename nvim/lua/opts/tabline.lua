local api = vim.api

vim.o.tabline = '%{%v:lua.SaffTabLine()%}'

function _G.SaffTabLine()
  local s = ''

  for _, tab in ipairs(api.nvim_list_tabpages()) do
    local hl, cross
    if tab == api.nvim_get_current_tabpage() then
      hl, cross = '%#TabLineSel#', '%999Xx'
    else
      hl, cross = '%#TabLine#', ''
    end

    local n   = api.nvim_tabpage_get_number(tab)
    local win = api.nvim_tabpage_get_win(tab)
    local buf = api.nvim_win_get_buf(win)

    local name = api.nvim_buf_get_name(buf)
    if name == '' then
      name = '[No Name]'
    else
      local short = vim.fn.fnamemodify(name, ':t')
      if short ~= '' then
        name = short
      end
    end

    s = s .. hl .. '%' .. n .. 'T' .. ' ' .. name .. ' ' .. cross .. ' '
  end

  s = s .. '%#TabLineFill#%T'
  return s
end
