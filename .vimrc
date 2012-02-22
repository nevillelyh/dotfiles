" basic settings
set nocompatible
source $VIMRUNTIME/vimrc_example.vim
behave xterm

set background=dark
set nobackup

set expandtab
set shiftwidth=4
set smarttab
set tabstop=8
syntax on
set foldmethod=syntax

" visible tabs and returns
set listchars=tab:»·,eol:↵
set list

""""""""""""""""""""
" Vundle
""""""""""""""""""""

set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

" look and feel
Bundle 'altercation/vim-colors-solarized'
Bundle 'Lokaltog/vim-powerline'

" Git
Bundle 'tpope/vim-git'
Bundle 'tpope/vim-fugitive'
Bundle 'gregsexton/gitv'

" code style
Bundle 'ciaranm/detectindent'
Bundle 'bitc/vim-bad-whitespace'
Bundle 'nathanaelkane/vim-indent-guides'

" navigation
Bundle 'scrooloose/nerdtree'
Bundle 'majutsushi/tagbar'
Bundle 'milkypostman/vim-togglelist'

" shortcuts
Bundle 'Raimondi/delimitMate'
Bundle 'nevillelyh/snipmate.vim'
Bundle 'tpope/vim-commentary'
Bundle 'ervandew/supertab'

" syntax check
Bundle 'scrooloose/syntastic'
Bundle 'tmhedberg/SimpylFold'

" syntax support
Bundle 'vim-scripts/google.vim'
Bundle 'derekwyatt/vim-scala'
Bundle 'jboyens/vim-protobuf'
Bundle 'jnwhiteh/vim-golang'
Bundle 'pangloss/vim-javascript'

filetype plugin indent on

""""""""""""""""""""
" key mappings
""""""""""""""""""""

" utility panes
map <ESC>1 :NERDTreeToggle<CR>
map <ESC>2 :TagbarToggle<CR>
" toggle quick fix and location list
map <ESC>3 <leader>q
map <ESC>4 <leader>l
" window navigation
map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
" tab navigation
map <C-N> gt
map <C-P> gT
" goto file in new tab
map gf <C-W>gf
" toggle folding
nmap <space> za

""""""""""""""""""""
" column guides
""""""""""""""""""""

function! ColumnsGuidesOn()
    if exists('+colorcolumn')
        highlight ColorColumn ctermbg=17
        set colorcolumn=80,100
    else
        let w:m2=matchadd('WarningMsg', '\%>80v.\+', -1)
        let w:m2=matchadd('ErrorMsg', '\%>100v.\+', -1)
    endif
endfunction

function! ColumnsGuidesOff()
    if exists('+colorcolumn')
        set colorcolumn=""
    else
        let w:m2=clearmatches()
    endif
endfunction

""""""""""""""""""""
" bundles
""""""""""""""""""""

function! OnBufOpen()
    " specific file types only
    let l:filetypes = [
                \ 'c', 'cpp', 'java', 'scala',
                \ 'html', 'css', 'javascript',
                \ 'perl', 'php', 'python', 'ruby',
                \ 'vim', 'sh', 'zsh',
                \ 'proto',
                \ ]
    if index(l:filetypes, &filetype) >= 0
        call ColumnsGuidesOn()
        call indent_guides#enable()

        " open all folds
        :execute "normal zR"
    else
        call ColumnsGuidesOff()
        call indent_guides#disable()
    endif
endfunction

autocmd BufRead,BufNewFile * :call OnBufOpen()

" Solarized color scheme
let g:solarized_termcolors=256
let g:solarized_termtrans=1
colorscheme solarized

" Powerline
set laststatus=2
let g:Powerline_symbols='fancy'

" DetectIndent
let g:detectindent_preferred_expandtab = 1
let g:detectindent_preferred_indent = 4
autocmd BufReadPost * :DetectIndent

" Ident guides
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 1

" Tagbar
let g:tagbar_left = 1

" OmniCompletion
set omnifunc=syntaxcomplete#Complete
" OmniCompletion with SuperTab
let g:SuperTabDefaultCompletionType = '<C-X><C-O>'
" Close pop up window after leaving insert mode
autocmd InsertLeave * if pumvisible() == 0 | pclose | endif

" Syntastic
let g:syntastic_check_on_open=1

""""""""""""""""""""
" non-GUI settings
""""""""""""""""""""

if !has('gui_running')
    " turn off mouse
    set mouse-=a
    " really dark grey non-intrusive colors
    let g:indent_guides_auto_colors = 0
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=234
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=236
endif
