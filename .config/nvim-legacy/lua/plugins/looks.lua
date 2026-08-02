return {
  {
    'dracula/vim',
    priority = 100,
    init = function()
      if vim.fn.has('gui_running') then
        vim.g.dracula_colorterm = 0
      end
    end,
  },
  {
    'edkolev/tmuxline.vim',
    init = function()
      vim.g.tmuxline_theme = 'powerline'
      vim.g.tmuxline_preset = 'powerline'
    end,
  },
  { 'tpope/vim-sleuth' },
  {
    'vim-airline/vim-airline',
    init = function()
      vim.g['airline_powerline_fonts'] = 1
      vim.g['airline#extensions#tabline#enabled'] = 1
      vim.g['airline#extensions#tmuxline#enabled'] = 0
    end,
  },
}
