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
" key mappings
""""""""""""""""""""

" left-hand pane
map <ESC>1 :NERDTreeToggle<CR>
map <ESC>2 :TagbarToggle<CR>
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
" plug-ins
""""""""""""""""""""

" Pathogen
call pathogen#infect()

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

" DetectIndent
let g:detectindent_preferred_expandtab = 1
let g:detectindent_preferred_indent = 4
autocmd BufReadPost * :DetectIndent

" Ident guides
let g:indent_guides_guide_size = 1
let g:indent_guides_start_level = 1

" OmniCompletion
set omnifunc=syntaxcomplete#Complete
" OmniCompletion with SuperTab
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
" Close pop up window after leaving insert mode
autocmd InsertLeave * if pumvisible() == 0 | pclose | endif

" Syntastic
let g:syntastic_check_on_open=1

" Tagbar
let g:tagbar_left = 1

" Conque shell
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_InsertOnEnter = 1
let g:ConqueTerm_CloseOnEnd = 1
command Shell :ConqueTerm zsh --login
command Hshell :ConqueTermSplit zsh --login
command Vshell :ConqueTermVSplit zsh --login

""""""""""""""""""""
" non-GUI settings
""""""""""""""""""""

if !has("gui_running")
    " turn off mouse
    set mouse-=a
    " really dark grey non-intrusive colors
    let g:indent_guides_auto_colors = 0
    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=234
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=236
endif
