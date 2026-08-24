local o = vim.o

require('opts.netrw')
require('opts.path')

o.title      = true
o.exrc       = true
o.confirm    = true
o.cursorline = true
o.undofile   = true
o.backupcopy = 'yes'
o.clipboard  = 'unnamedplus'
o.scrolloff  = 8

o.number         = true
o.relativenumber = true
o.signcolumn     = 'yes'

o.laststatus = 3
o.cmdheight  = 0

o.linebreak   = true
o.breakindent = true

o.splitright = true
o.splitbelow = true

o.winborder = 'rounded'
o.pumborder = 'rounded'

o.list      = true
o.listchars = 'tab:> ,trail:·,nbsp:+'
o.fillchars = 'eob: '

o.shiftwidth  = 2
o.softtabstop = -1
o.expandtab   = true

o.ignorecase = true
o.smartcase  = true
o.inccommand = 'split'

o.completeopt = 'menuone,noselect,fuzzy,popup'
o.wildmode    = 'noselect:lastused,full'
o.wildoptions = 'pum,tagfile,fuzzy'
