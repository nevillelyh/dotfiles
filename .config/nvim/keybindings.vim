" Window navigation
nmap <C-H> <C-W>h
nmap <C-J> <C-W>j
nmap <C-K> <C-W>k
nmap <C-L> <C-W>l

" Tab navigation
nmap <C-P> gT
nmap <C-N> gt

" Buffer navigation
nmap <silent> <A-p> :bprevious<CR>
nmap <silent> <A-n> :bnext<CR>
nmap <silent> <A-w> :bdelete<CR>

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
