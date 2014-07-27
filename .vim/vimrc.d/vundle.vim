""""""""""""""""""""
" Vundle
""""""""""""""""""""
set nocompatible
"filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

" Look and feel
Bundle 'Lokaltog/vim-powerline'
Bundle 'altercation/vim-colors-solarized'

" Git
Bundle 'gregsexton/gitv'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-git'

" Code style
Bundle 'bitc/vim-bad-whitespace'
Bundle 'ciaranm/detectindent'
Bundle 'nathanaelkane/vim-indent-guides'

" Navigation
Bundle 'derekwyatt/vim-fswitch'
Bundle 'wincent/Command-T'
Bundle 'majutsushi/tagbar'
Bundle 'milkypostman/vim-togglelist'
Bundle 'scrooloose/nerdtree'

" Shortcuts
Bundle 'Raimondi/delimitMate'
Bundle 'nevillelyh/snipmate.vim'
Bundle 'scrooloose/nerdcommenter'
"if v:version < 703
"    Bundle 'ervandew/supertab'
"else
"    Bundle 'Valloric/YouCompleteMe'
"endif

" Syntax check
Bundle 'scrooloose/syntastic'
Bundle 'tmhedberg/SimpylFold'

" Syntax support
Bundle 'derekwyatt/vim-scala'
Bundle 'guns/vim-clojure-static'
Bundle 'jboyens/vim-protobuf'
Bundle 'jnwhiteh/vim-golang'
Bundle 'kien/rainbow_parentheses.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'plasticboy/vim-markdown'
Bundle 'vim-scripts/google.vim'

filetype plugin indent on
syntax on
