return {
  {
    "williamboman/mason.nvim",
  },
  {
    "williamboman/mason-lspconfig.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "basedpyright",
          "clangd",
          "gopls",
          "lua_ls",
          "ruff",
          "rust_analyzer",
          "terraformls",
        },
      })

      local lspconfig = require("lspconfig")

      --------------------

      lspconfig.basedpyright.setup({
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
            },
          },
        },
      })
      lspconfig.clangd.setup({})
      lspconfig.gopls.setup({})
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = {"vim"},
            },
          }
        },
      })
      lspconfig.metals.setup({})
      lspconfig.ruff.setup({})
      lspconfig.rust_analyzer.setup({})
    end,
  },
}
