" remote origin, i.e. git.spotify.net:client.git
let s:origin = system('git config --get remote.origin.url')

if match(s:origin, '\<git.spotify.net\>', 0) >= 0
  autocmd FileType c setlocal shiftwidth=2
  autocmd FileType cpp setlocal shiftwidth=2
  autocmd FileType html setlocal shiftwidth=2
  autocmd FileType css setlocal shiftwidth=2
  autocmd FileType javascript setlocal shiftwidth=2
  autocmd BufRead,BufNewFile *.proto setlocal shiftwidth=8 noexpandtab
  autocmd BufRead,BufNewFile *.boink setlocal shiftwidth=8 noexpandtab
endif
