""""""""""""""""""""
" Basics
""""""""""""""""""""

" Look and feel
behave xterm
set background=dark
set nocompatible
set backspace=indent,eol,start
set nobackup
set history=50
set ruler
set showcmd

" Tab behavior
set shiftwidth=4
set tabstop=8
set expandtab
set smarttab

" Indentation
set autoindent
set smartindent

" Search
set incsearch
set hlsearch
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
nmap <C-N> gt
nmap <C-P> gT

" Buffer navigation
nmap <ESC>p :bprev<CR>
nmap <ESC>n :bnext<CR>

" Goto file in new tab
nmap gf <C-W>gf
" Toggle folding
nmap <space> za

" For all text files set 'textwidth' to 78 characters.
autocmd FileType text setlocal textwidth=78

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.
autocmd BufReadPost *
\ if line("'\"") > 1 && line("'\"") <= line("$") |
\   exe "normal! g`\"" |
\ endif

" turn off mouse in terminal
if !has('gui_running')
    set mouse-=a
endif

function LoadFile(name)
  let l:path = $HOME."/.vim/vimrc.d/" . a:name . ".vim"
  if filereadable(l:path)
    :exec ":source " . l:path
  endif
endfunction

:call LoadFile("vundle")
:call LoadFile("bundle_maps")
:call LoadFile("bundle_settings")
:call LoadFile("autocommands")
