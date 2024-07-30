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
