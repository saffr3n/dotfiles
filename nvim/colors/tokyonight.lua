local hl = {
}

for name, config in pairs(hl) do
  vim.api.nvim_set_hl(0, name, config)
end
