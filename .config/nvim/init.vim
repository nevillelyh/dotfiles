"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/home/neville/.local/share/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('/home/neville/.local/share/dein')
  call dein#begin('/home/neville/.local/share/dein')

  " Let dein manage dein
  " Required:
  call dein#add('/home/neville/.local/share/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here like this:
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')
  call dein#add('vim-airline/vim-airline')
  call dein#add('edkolev/tmuxline.vim')

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

" Look and feel
behave xterm
let g:airline_powerline_fonts = 1

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

" Window navigation
nmap <C-H> <C-W>h
nmap <C-J> <C-W>j
nmap <C-K> <C-W>k
nmap <C-L> <C-W>l

" Tab navigation
nmap <C-P> gT
nmap <C-N> gt

" Buffer navigation
nmap <A-p> :bprevious<CR>
nmap <A-n> :bnext<CR>
