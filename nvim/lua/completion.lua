local o           = vim.o
local map         = vim.keymap.set
local keycode     = vim.keycode
local wildtrigger = vim.fn.wildtrigger
local api         = vim.api

o.completeopt = 'menuone,noselect,fuzzy,popup'
o.wildmode    = 'noselect:lastused,full'
o.wildoptions = 'pum,tagfile,fuzzy'

---@param name string
local function augrp(name)
  return api.nvim_create_augroup(name, { clear = true })
end

---@param group integer
---@param event vim.api.keyset.events
---@param cb    fun(args: vim.api.keyset.create_autocmd.callback_args): boolean?
local function aucmd(group, event, cb)
  api.nvim_create_autocmd(event, { group = group, callback = cb })
end

---@param keys string
local function feedkeys(keys)
  api.nvim_feedkeys(keys, 'n', false)
end

local lsp_cmp_grp   = augrp('saff.lsp-cmp')
local is_lsp_cmp_on = false

aucmd(lsp_cmp_grp, 'LspAttach', function(e)
  local buf = e.buf
  local cmp = vim.lsp.completion

  cmp.enable(true, e.data.client_id, buf)

  map('i', '<C-Space>', function()
    is_lsp_cmp_on = not is_lsp_cmp_on

    if is_lsp_cmp_on then
      cmp.get()
    else
      feedkeys(keycode('<C-e>'))
    end
  end, { buf = buf })

  aucmd(lsp_cmp_grp, 'CursorMovedI', function()
    if is_lsp_cmp_on then cmp.get() end
  end)

  aucmd(lsp_cmp_grp, 'InsertLeave', function()
    is_lsp_cmp_on = false
  end)
end)

local cmd_cmp_grp   = augrp('saff.cmd-cmp')
local is_cmd_cmp_on = false

map('c', '<C-Space>', function()
  is_cmd_cmp_on = not is_cmd_cmp_on

  if is_cmd_cmp_on then
    wildtrigger()
  else
    feedkeys(keycode('<C-e>'))
  end
end)

aucmd(cmd_cmp_grp, 'CmdlineChanged', function()
  if is_cmd_cmp_on then wildtrigger() end
end)

aucmd(cmd_cmp_grp, 'CmdlineLeave', function()
  is_cmd_cmp_on = false
end)
