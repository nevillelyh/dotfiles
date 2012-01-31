" .vim file in the git-repo root, i.e. ~/src/client/.vim
let s:localvim = split(system('git rev-parse --show-toplevel'))[0].'/.vim'

" remote origin, i.e. git.spotify.net:client.git
let s:origin = system('git config --get remote.origin.url')

if filereadable(s:localvim)
 :exec ':source ' . s:localvim
elseif match(s:origin, '\<git.spotify.net\>', 0) >= 0
  autocmd FileType c setlocal shiftwidth=8 noexpandtab
  autocmd FileType cpp setlocal shiftwidth=8 noexpandtab
  autocmd FileType css setlocal shiftwidth=8 noexpandtab
  autocmd FileType javascript setlocal shiftwidth=8 noexpandtab
  autocmd BufRead,BufNewFile *.proto setlocal shiftwidth=8 noexpandtab
  autocmd BufRead,BufNewFile *.boink setlocal shiftwidth=8 noexpandtab
endif
