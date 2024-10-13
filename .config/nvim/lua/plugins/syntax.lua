return {
  -- { 'hashivim/vim-terraform' },
  -- { 'jjo/vim-cue' },
  -- { 'zchee/vim-flatbuffers' },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local c = require('nvim-treesitter.configs')
      c.setup ({
        ensure_installed = {
          'bash',
          'c',
          'cpp',
          'dockerfile',
          'go',
          'java',
          'javascript',
          'kotlin',
          'lua',
          'markdown',
          'python',
          'rust',
          'scala',
          'sql',
          'terraform',
          'typescript',
          'vim',
        },
        sync_install = false,
        highlight = { enable = true },
        incremental_selection = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
