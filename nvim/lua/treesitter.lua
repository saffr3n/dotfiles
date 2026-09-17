local bo  = vim.bo
local wo  = vim.wo
local ts  = vim.treesitter
local cmd = vim.cmd
local api = vim.api

local plugin             = 'nvim-treesitter'
local default_foldmethod = vim.o.foldmethod
local group              = api.nvim_create_augroup('saff.ts', { clear = true })

vim.pack.add({ 'https://github.com/' .. plugin .. '/' .. plugin })

-- nvim comes with these parsers pre-installed: c, diff, lua, markdown, query, vimscript, vimdoc
require(plugin).install({
  'java',
  'javascript',
  'jsdoc',
  'luadoc',
  'nix',
})

local function set_default_foldmethod()
  wo.foldmethod = default_foldmethod
end

---@param event vim.api.keyset.events
---@param cb    fun(args: vim.api.keyset.create_autocmd.callback_args): boolean?
local function aucmd(event, cb)
  api.nvim_create_autocmd(event, { group = group, callback = cb })
end

aucmd('BufWinEnter', function(e)
  local buf  = e.buf
  local lang = ts.language.get_lang(bo.filetype)

  if not lang or not ts.language.add(lang) then
    return set_default_foldmethod()
  end

  ts.start(buf, lang)

  local has_folds = ts.query.get(lang, 'folds') ~= nil
  if has_folds then
    wo.foldmethod = 'expr'
    wo.foldexpr   = 'v:lua.vim.treesitter.foldexpr()'
  else
    set_default_foldmethod()
  end

  local has_indent = ts.query.get(lang, 'indents') ~= nil
  if has_indent then
    bo.indentexpr = 'v:lua.require("' .. plugin .. '").indentexpr()'
  end
end)

aucmd('PackChanged', function(e)
  local data = e.data
  if data.spec.name ~= plugin then return end

  local kind = data.kind
  if kind ~= 'install' and kind ~= 'update' then return end

  if not data.active then
    cmd.packadd(plugin)
  end

  cmd('TSUpdate')
end)
