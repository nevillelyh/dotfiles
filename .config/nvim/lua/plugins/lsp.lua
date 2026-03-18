return {
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
    },
    opts = {
      ensure_installed = {
        'basedpyright',
        'gopls',
        'lua_ls',
        'ruff',
        'ts_ls',
      },
    },
  },
  {
    'saghen/blink.cmp',
    version = '1.*',
    opts = {
      keymap = { preset = 'enter' },
      completion = { documentation = { auto_show = true } },
    },
  },
}
