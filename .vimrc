set nocompatible
source $VIMRUNTIME/vimrc_example.vim
behave xterm

set background=dark
set mouse-=a
set nobackup

set expandtab
set shiftwidth=4
set smarttab
set tabstop=8
syntax on

" Highlight column 80+
if exists('+colorcolumn')
    highlight ColorColumn ctermbg=cyan
    set colorcolumn=80,100
else
    au BufWinEnter * let w:m2=matchadd('WarningMsg', '\%>80v.\+', -1)
    au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>100v.\+', -1)
endif

" Pathogen
call pathogen#infect()

" Omni Completion
set omnifunc=syntaxcomplete#Complete
" Omni Completion with SuperTab
let g:SuperTabDefaultCompletionType = "<C-X><C-O>"
" Close pop up window after leaving insert mode
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" NERDTree
map <F5> :NERDTreeToggle<CR>

" Tagbar
map <F6> :TagbarToggle<CR>
let g:tagbar_left = 1

" Conque shell
let g:ConqueTerm_CWInsert = 1
let g:ConqueTerm_InsertOnEnter = 1
let g:ConqueTerm_CloseOnEnd = 1
command Shell :ConqueTerm zsh --login
command Hshell :ConqueTermSplit zsh --login
command Vshell :ConqueTermVSplit zsh --login
