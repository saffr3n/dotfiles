local langs = { 'nix', 'java' }

vim.pack.add({ 'https://github.com/nvim-treesitter/nvim-treesitter' })

require('nvim-treesitter').install(langs)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('ts-start', { clear = true }),
  callback = function(event)
    local lang = vim.treesitter.language.get_lang(event.match)
    if not lang or not vim.treesitter.language.add(lang) then return end
    vim.treesitter.start(event.buf, lang)
  end,
})
