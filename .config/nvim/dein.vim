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
  " Look & Feel
  call dein#add('dracula/vim', {'merged': 0})
  call dein#add('edkolev/tmuxline.vim', {'merged': 0})
  call dein#add('ntpeters/vim-better-whitespace', {'merged': 0})
  call dein#add('tpope/vim-sleuth', {'merged': 0})
  call dein#add('vim-airline/vim-airline', {'merged': 0})

  " Coding & Editing
  call dein#add('airblade/vim-gitgutter', {'merged': 0}) " [c,]c => prev/next hunk
  call dein#add('godlygeek/tabular', {'merged': 0})
  call dein#add('junegunn/fzf', {'merged': 0})
  call dein#add('kamykn/spelunker.vim', {'merged': 0})
  call dein#add('preservim/nerdcommenter', {'merged': 0})
  call dein#add('tpope/vim-fugitive', {'merged': 0})
  call dein#add('vim-syntastic/syntastic', {'merged': 0})

  " Syntax
  call dein#add('hashivim/vim-terraform', {'merged': 0})
  call dein#add('jjo/vim-cue', {'merged': 0})
  call dein#add('preservim/vim-markdown', {'merged': 0})
  call dein#add('udalov/kotlin-vim', {'merged': 0})
  call dein#add('zchee/vim-flatbuffers', {'merged': 0})

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
