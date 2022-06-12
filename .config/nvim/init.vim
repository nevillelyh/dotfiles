" Look and feel
behave xterm
set termguicolors
set mouse=a

" Tabs and spaces
set shiftwidth=4
set expandtab

" Indentation
set smartindent

" Search
set ignorecase
set smartcase

" Visible characters
set listchars=tab:»·,eol:↵,trail:⋅,extends:❯,precedes:❮
set list
set colorcolumn=80,100

if !exists('g:vscode')
  set keymap=
  function! ToggleKeymap()
    if &keymap == ""
      set keymap=colemak
    else
      set keymap=
    endif
  endfunction
  nmap <silent> <C-Space> :call ToggleKeymap()<CR>

  source $HOME/.config/nvim/dein.vim
  source $HOME/.config/nvim/keybindings.vim
  source $HOME/.config/nvim/plugins.vim
endif
