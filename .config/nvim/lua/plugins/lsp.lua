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
      local lsps = {
          "basedpyright",
          "gopls",
          "lua_ls",
          "ruff",
          "rust_analyzer",
          "terraformls",
      }
      local uname = vim.loop.os_uname()
      local platform = uname.sysname .. "-" .. uname.machine
      if platform ~= "Linux-aarch64" then
        table.insert(lsps, "clangd")
      end
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = lsps,
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
