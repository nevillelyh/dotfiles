return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- ShellCheck for sh/bash
        bashls = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- LazyVim defaults to shfmt for sh/bash
        zsh = { "shfmt" },
      },
    },
  },
}
