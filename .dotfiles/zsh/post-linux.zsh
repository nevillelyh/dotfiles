alias open='xdg-open'
alias dgrun='docker run --gpus all --privileged'

# copy/paste
xc() {
    if [[ -t 0 ]]; then
        xclip -selection clipboard -out
    else
        # read from stdin
        xclip -selection clipboard -in
    fi
}

FD_COMMAND=fd
# fd is already used by package fdclone on Ubuntu 19.04 or later
if type fdfind &> /dev/null; then
    alias fd='fdfind'
    FD_COMMAND=fdfind
fi
export FD_COMMAND
