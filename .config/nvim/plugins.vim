" Look and feel
if !has('gui_running')
  let g:dracula_colorterm = 0
endif
colorscheme dracula
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tmuxline#enabled = 0
let g:tmuxline_theme = 'powerline'
let g:tmuxline_preset = 'powerline'

" FZF
let g:fzf_action = { 'ctrl-t': 'tab split', 'ctrl-s': 'split', 'ctrl-v': 'vsplit' }
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6, 'relative': v:true, 'yoffset': 0.1 } }
" Alt-O - with FZF_DEFAULT_COMMAND='fd -type f'
" Alt-Shift-O - with system 'find' which includes ignored files
nmap <A-o> :FZF<CR>
nmap <A-O> :call fzf#run(fzf#wrap({'source': 'find . -type f'}))<CR>

" NERD Commenter
" Alt-/ - Comment line(s)
" Alt-Shift-/ - Comment block
let g:NERDSpaceDelims = 1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
nmap <A-/> <leader>c<space><Down>
vmap <A-/> <leader>c<space>
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
let g:syntastic_python_flake8_args = "--max-line-length=100"
let g:syntastic_sh_shellcheck_args = "-x"
