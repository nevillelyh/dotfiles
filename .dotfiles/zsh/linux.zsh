alias open='xdg-open'

FD_COMMAND=fd
# fd is already used by package fdclone on Ubuntu 19.04 or later
if type fdfind &> /dev/null; then
    alias fd='fdfind'
    FD_COMMAND=fdfind
fi
export FD_COMMAND

export PATH=$HOME/.dotfiles/bin/linux:$PATH
[[ -d $HOME/.nvman ]] && eval $(nvman env)
