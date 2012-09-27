""""""""""""""""""""
" Vundle
""""""""""""""""""""
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

" Look and feel
Bundle 'altercation/vim-colors-solarized'
Bundle 'Lokaltog/vim-powerline'

" Git
Bundle 'tpope/vim-git'
Bundle 'tpope/vim-fugitive'
Bundle 'gregsexton/gitv'

" Code style
Bundle 'ciaranm/detectindent'
Bundle 'bitc/vim-bad-whitespace'
Bundle 'nathanaelkane/vim-indent-guides'

" Navigation
Bundle 'scrooloose/nerdtree'
Bundle 'majutsushi/tagbar'
Bundle 'milkypostman/vim-togglelist'
Bundle 'git://git.wincent.com/command-t.git'
Bundle 'ZoomWin'
Bundle 'derekwyatt/vim-fswitch'

" Shortcuts
Bundle 'Raimondi/delimitMate'
Bundle 'nevillelyh/snipmate.vim'
Bundle 'scrooloose/nerdcommenter'
Bundle 'ervandew/supertab'

" Syntax check
Bundle 'scrooloose/syntastic'
Bundle 'tmhedberg/SimpylFold'

" Syntax support
Bundle 'vim-scripts/google.vim'
Bundle 'derekwyatt/vim-scala'
Bundle 'jboyens/vim-protobuf'
Bundle 'jnwhiteh/vim-golang'
Bundle 'pangloss/vim-javascript'
Bundle 'framallo/asciidoc.vim'

filetype plugin indent on
syntax on
