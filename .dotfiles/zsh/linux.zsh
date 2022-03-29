alias open='xdg-open'

FD_COMMAND=fd
# fd is already used by package fdclone on Ubuntu 19.04 or later
if type fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
    FD_COMMAND=fdfind
fi
export FD_COMMAND

[[ -d $HOME/.nvman ]] && eval $(nvman env)
