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
          "gopls",
          "lua_ls",
          "ruff",
          "rust_analyzer",
          "terraformls",
        },
      })

      require("lspconfig").lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = {"vim"},
            },
          }
        },
      })
    end,
  },
}
