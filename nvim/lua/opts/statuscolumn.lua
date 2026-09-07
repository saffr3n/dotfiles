local o = vim.o

o.statuscolumn   = '%{%v:lua.SaffStatusColumn()%}'
o.number         = true
o.relativenumber = true
o.signcolumn     = 'yes'
o.foldcolumn     = '1'
o.foldtext       = ''
o.foldmethod     = 'indent'
o.foldlevel      = 99

function _G.SaffStatusColumn()
  return '%l%s%C'
end
