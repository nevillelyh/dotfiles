""""""""""""""""""""
" Vundle
""""""""""""""""""""
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#begin()
Plugin 'gmarik/vundle'

" Look and feel
Plugin 'bling/vim-airline'
Plugin 'edkolev/tmuxline.vim'
Plugin 'tomasr/molokai'

" Git
Plugin 'gregsexton/gitv'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-git'
Plugin 'airblade/vim-gitgutter'

" Code style
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'ciaranm/detectindent'
Plugin 'nathanaelkane/vim-indent-guides'

" Navigation
Plugin 'derekwyatt/vim-fswitch'
Plugin 'wincent/Command-T'
Plugin 'majutsushi/tagbar'
Plugin 'milkypostman/vim-togglelist'
Plugin 'scrooloose/nerdtree'
Plugin 'Lokaltog/vim-easymotion'

" Shortcuts
Plugin 'Raimondi/delimitMate'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
Plugin 'scrooloose/nerdcommenter'
"if v:version < 703
"    Bundle 'ervandew/supertab'
"else
"    Bundle 'Valloric/YouCompleteMe'
"endif

" Syntax check
Plugin 'scrooloose/syntastic'
Plugin 'tmhedberg/SimpylFold'

" Syntax support
Plugin 'derekwyatt/vim-scala'
Plugin 'guns/vim-clojure-static'
Plugin 'jboyens/vim-protobuf'
Plugin 'jnwhiteh/vim-golang'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'plasticboy/vim-markdown'
Plugin 'vim-scripts/google.vim'

call vundle#end()
filetype plugin indent on
syntax on
