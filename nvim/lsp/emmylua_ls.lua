return {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = { '.git', '.stylua.toml' },
  workspace_required = false,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { library = { vim.env.VIMRUNTIME } },
    },
  },
}
