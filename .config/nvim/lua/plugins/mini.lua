return {
  {
    'echasnovski/mini.nvim',
    version = false,
    init = function()
      -- ga, gA
      require('mini.align').setup()
      require('mini.completion').setup()
      require('mini.cursorword').setup()
      require('mini.pairs').setup()
      require('mini.trailspace').setup()
    end,
  },
}
