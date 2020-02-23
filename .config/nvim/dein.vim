"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=$HOME/.local/share/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state($HOME.'/.local/share/dein')
  call dein#begin($HOME.'/.local/share/dein')

  " Let dein manage dein
  " Required:
  call dein#add($HOME.'/.local/share/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here like this:
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')
  call dein#add('crusoexia/vim-monokai')
  call dein#add('vim-airline/vim-airline')
  call dein#add('edkolev/tmuxline.vim')
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('tpope/vim-sleuth')
  call dein#add('tpope/vim-fugitive')
  call dein#add('airblade/vim-gitgutter') " [c/]c: prev/next hunk
  call dein#add('preservim/nerdcommenter')
  call dein#add('vim-syntastic/syntastic')
  call dein#add('junegunn/fzf')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

"End dein Scripts-------------------------
