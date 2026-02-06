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

      --------------------

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
            },
          },
        },
      })
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = {"vim"},
            },
          }
        },
      })


      vim.lsp.enable({
        "basedpyright",
        "clangd",
        "gopls",
        "lua_ls",
        "metals",
        "ruff",
        "ruff_analyzer",
      })
    end,
  },
}
