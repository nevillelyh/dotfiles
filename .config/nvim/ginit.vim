if exists(':GuiFont')
  GuiFont! MesloLGS NF:h9
endif

" https://github.com/equalsraf/neovim-qt/issues/219
if exists('g:GuiLoaded')
  let g:dracula_colorterm = 1
  colorscheme dracula
endif
