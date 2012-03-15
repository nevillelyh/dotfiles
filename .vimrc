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

""""""""""""""""""""
" Vundle
""""""""""""""""""""

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

""""""""""""""""""""
" Bundle shortcuts
""""""""""""""""""""

let g:side_bar_open = ''
function! SideBar(side_bar)
    if g:side_bar_open == a:side_bar
        :NERDTreeClose
        :TagbarClose
        let g:side_bar_open = ''
        return
    endif
    if a:side_bar == 'NERDTree'
        :TagbarClose
        :NERDTree
    elseif a:side_bar == 'Tagbar'
        :NERDTreeClose
        :TagbarOpen
    endif
    let g:side_bar_open = a:side_bar
endfunction

" Utility panes
nmap <silent> <ESC>1 :call SideBar('NERDTree')<CR>
nmap <silent> <ESC>2 :call SideBar('Tagbar')<CR>

" Toggle quickfix and location list
nmap <ESC>3 <leader>q
nmap <ESC>4 <leader>l

" Command-T
nmap <ESC>t :CommandT<CR>
nmap <ESC>T :CommandTBuffer<CR>

" ZoomWin
nmap <C-Z> :ZoomWin<CR>

""""""""""""""""""""
" Auto Commands
""""""""""""""""""""

function! ColumnsGuidesOn()
    if exists('+colorcolumn')
        highlight ColorColumn ctermbg=17
        setlocal colorcolumn=80,100
    else
        let w:m2=matchadd('WarningMsg', '\%>80v.\+', -1)
        let w:m2=matchadd('ErrorMsg', '\%>100v.\+', -1)
    endif
endfunction

function! ColumnsGuidesOff()
    if exists('+colorcolumn')
        setlocal colorcolumn=""
    else
        let w:m2=clearmatches()
    endif
endfunction

function! AutoCommand()
    " fallback fold method
    if &foldmethod == 'manual' && &filetype != ''
        set foldmethod=indent
    endif

    " specific file types only
    let l:filetypes = [
                \ 'c', 'cpp', 'java', 'scala',
                \ 'html', 'css', 'javascript',
                \ 'perl', 'php', 'python', 'ruby',
                \ 'haskell',
                \ 'vim', 'sh', 'zsh',
                \ 'proto',
                \ ]
    if index(l:filetypes, &filetype) >= 0
        call ColumnsGuidesOn()
        call indent_guides#enable()

        " open all folds
        :execute 'normal zR'
    else
        call ColumnsGuidesOff()
        call indent_guides#disable()
    endif
endfunction

autocmd BufRead,BufNewFile *.asciidoc setfiletype asciidoc
autocmd BufRead,BufNewFile * :call AutoCommand()

""""""""""""""""""""
" bundles
""""""""""""""""""""

" Solarized color scheme
let g:solarized_termcolors = 256
let g:solarized_termtrans = 1
colorscheme solarized

" Powerline
set laststatus=2
let g:Powerline_symbols = 'fancy'

" DetectIndent
let g:detectindent_preferred_expandtab = 1
let g:detectindent_preferred_indent = 4
autocmd BufReadPost * :DetectIndent

" Ident guides
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 1

" NERDTree
let g:NERDTreeWinSize = 30

" Tagbar
let g:tagbar_left = 1
let g:tagbar_width = 30
let g:tagbar_sort = 0

" Command-T
let g:CommandTMatchWindowAtTop = 1

" NERDCommenter
let g:NERDSpaceDelims = 1

" OmniCompletion
set omnifunc=syntaxcomplete#Complete
" OmniCompletion with SuperTab
let g:SuperTabDefaultCompletionType = '<C-X><C-O>'
" Close pop up window after leaving insert mode
autocmd InsertLeave * if pumvisible() == 0 | pclose | endif

" Syntastic
let g:syntastic_check_on_open = 1

""""""""""""""""""""
" non-GUI settings
""""""""""""""""""""

if !has('gui_running')
    " turn off mouse
    set mouse-=a
    " really dark grey non-intrusive colors
    let g:indent_guides_auto_colors = 0
    autocmd VimEnter,Colorscheme * :highlight IndentGuidesOdd  ctermbg=234
    autocmd VimEnter,Colorscheme * :highlight IndentGuidesEven ctermbg=236
endif
