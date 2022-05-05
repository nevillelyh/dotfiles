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
  source $HOME/.config/nvim/dein.vim
  source $HOME/.config/nvim/keybindings.vim
  source $HOME/.config/nvim/plugins.vim
endif
