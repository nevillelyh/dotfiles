" Look and feel
let g:dracula_colorterm = 0
colorscheme dracula
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0
let g:tmuxline_theme = 'nightly_fox'
let g:tmuxline_preset = 'minimal'

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
let g:syntastic_cpp_compiler_options = '-std=c++20'