source $HOME/.config/nvim/dein.vim

" Look and feel
behave xterm
colorscheme monokai
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:tmuxline_preset = 'nightly_fox'

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
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
