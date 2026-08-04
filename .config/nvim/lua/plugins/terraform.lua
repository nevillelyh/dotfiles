return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = { enabled = false },
        tofu_ls = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        terraform_fmt = {
          command = "tofu",
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        terraform_validate = function()
          local linter = require("lint.linters.terraform_validate")()
          linter.cmd = "tofu"
          return linter
        end,
      },
    },
  },
}
