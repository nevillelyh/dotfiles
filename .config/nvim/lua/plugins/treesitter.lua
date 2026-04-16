local languages = {
  'bash',
  'c',
  'cpp',
  'css',
  'diff',
  'dockerfile',
  'go',
  'java',
  'javascript',
  'html',
  'kotlin',
  'lua',
  'markdown',
  'markdown_inline',
  'proto',
  'python',
  'rust',
  'scala',
  'sql',
  'swift',
  'terraform',
  'toml',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
}

-- Clean install nvim-treesitter
-- rm -rf ~/.local/share/nvim/lazy/nvim-treesitter && nvim --headless '+Lazy! sync nvim-treesitter' +qa
-- Clean install nvim-treesitter parsers
-- rm -rf ~/.local/share/nvim/site/{parser,queries,parser-info} && nvim --headless '+lua TSInstallParsers():wait(300000)' +qa
function _G.TSInstallParsers()
  return require('nvim-treesitter').install(languages)
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local treesitter = require('nvim-treesitter')
      treesitter.setup()

      local filetypes = {}
      for _, lang in ipairs(languages) do
        vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(lang))
      end

      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function(event)
          pcall(vim.treesitter.start, event.buf)
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
