source $HOME/.config/nvim/dein.vim

" Look and feel
behave xterm
set termguicolors
set mouse=a
let g:dracula_colorterm = 0
colorscheme dracula
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0

" Tabs and spaces
set shiftwidth=4
set tabstop=4
set noexpandtab

" Indentation
set smartindent

" Search
set ignorecase
set smartcase

" Visible characters
set listchars=tab:»·,eol:↵,trail:⋅,extends:❯,precedes:❮
set list
set colorcolumn=80,100

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

" Folding
" Open/close
nmap <A-l> zo
nmap <A-h> zc
nmap <A-L> zO
nmap <A-H> zC
" Toggle
nmap <A-.> za
nmap <A-char-62> zA
" More/reduce
nmap <A-k> zm
nmap <A-j> zr
nmap <A-J> zR
nmap <A-K> zM

set keymap=
function! ToggleKeymap()
  if &keymap == ""
    set keymap=colemak
  else
    set keymap=
  endif
endfunction
nmap <silent> <C-Space> :call ToggleKeymap()<CR>
