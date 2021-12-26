source $HOME/.config/nvim/dein.vim

if exists('g:vv')
  VVset nobold
  VVset noitalic
  VVset fontfamily=Fira\ Mono\ for\ Powerline
  VVset fontsize=12
endif

" Look and feel
behave xterm
set termguicolors
set mouse=a
colorscheme dracula
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0
if has('mac')
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif
  "The default column number symbol is missing
  let g:airline_symbols.colnr = "\u2105:"
endif
let g:tmuxline_theme = 'nightly_fox'
let g:tmuxline_preset = 'minimal'

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
" Alt-O - with FZF_DEFAULT_COMMAND='fd -type f'
" Alt-Shift-O - with system 'find' which includes ignored files
nmap <A-o> :FZF<CR>
nmap <A-O> :call fzf#run(fzf#wrap({'source': 'find . -type f'}))<CR>

" NERD Commenter
" Alt-/ - Comment line(s)
" Alt-Shift-/ - Comment block
let g:NERDSpaceDelims = 1
nmap <A-/> <leader>ci<Down>
vmap <A-/> <leader>ci
vmap <A-?> <leader>cm

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = {'mode': 'active', 'passive_filetypes': ['java', 'scala']}

set colorcolumn=80,100
