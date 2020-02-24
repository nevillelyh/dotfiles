source $HOME/.config/nvim/dein.vim

" Look and feel
behave xterm
set termguicolors
colorscheme monokai
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0
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

" FZF
" Alt-O - git files
" Alt-Shift-O - all files
nmap <A-o> :call fzf#run(fzf#wrap({'source': 'git ls-files'}))<CR>
nmap <A-O> :FZF<CR>

" NERD Commenter
" Alt-/ - Comment line(s)
" Alt-Shift-/ - Comment block
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
