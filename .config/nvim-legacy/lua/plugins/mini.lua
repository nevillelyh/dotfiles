return {
  {
    'echasnovski/mini.nvim',
    version = false,
    init = function()
      -- ga, gA
      require('mini.align').setup()
      require('mini.cursorword').setup()
      require('mini.trailspace').setup()
    end,
  },
}
