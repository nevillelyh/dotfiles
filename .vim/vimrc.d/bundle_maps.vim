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

" Plugin shortcuts
nmap <silent> <ESC>1 :call SideBar('NERDTree')<CR>
nmap <silent> <ESC>2 :call SideBar('Tagbar')<CR>

" Toggle quickfix and location list
nmap <ESC>3 <leader>q
nmap <ESC>4 <leader>l

" Command-T
nmap <ESC>t :CommandT<CR>
nmap <ESC>T :CommandTBuffer<CR>

" FSwitch
nmap <ESC>h :FSHere<CR>

" NERDCommenter
nmap <ESC>/ <leader>ci<Down>
vmap <ESC>/ <leader>ci
