return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    -- Match the separator to the line-number gutter
    init = function()
      local function set_separator_highlight()
        vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "LineNr" })
      end

      set_separator_highlight()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_separator_highlight })
    end,
    opts = {
      separator = "─",
    },
  },
}
