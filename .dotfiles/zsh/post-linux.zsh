# Workaround for themes relative path
alias btop='/snap/btop/current/usr/local/bin/btop'

alias open='xdg-open'

FD_COMMAND=fd
# fd is already used by package fdclone on Ubuntu 19.04 or later
if type fdfind &> /dev/null; then
    alias fd='fdfind'
    FD_COMMAND=fdfind
fi
export FD_COMMAND
