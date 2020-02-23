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
  call dein#add('crusoexia/vim-monokai')
  call dein#add('vim-airline/vim-airline')
  call dein#add('edkolev/tmuxline.vim')
  call dein#add('junegunn/fzf')
  call dein#add('tpope/vim-fugitive')
  call dein#add('airblade/vim-gitgutter') " [c/]c: prev/next hunk
  call dein#add('ntpeters/vim-better-whitespace')
  call dein#add('tpope/vim-sleuth')
  call dein#add('preservim/nerdcommenter')

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
colorscheme monokai
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

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

" Plugins
nmap <A-t> :FZF<CR>
let g:NERDSpaceDelims = 1
nmap <A-/> <leader>ci<Down>
vmap <A-/> <leader>ci
vmap <A-?> <leader>cm
