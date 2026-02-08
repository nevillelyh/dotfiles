alias open='xdg-open'
alias dgrun='docker run --gpus all --privileged'

# copy/paste
xc() {
    if [[ -t 0 ]]; then
        # clipboard -> stdout
        wl-paste
    else
        # stdin -> clipboard
        wl-copy
    fi
}
