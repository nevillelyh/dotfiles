alias gvim='vimr'

pidof() {
    local name=$1
    ps axc 2> /dev/null | awk -v n="$name" '$5==n {print $1}'
}

export K9S_CONFIG_DIR="$HOME/.config/k9s"

# copy/paste
xc() {
    if [[ -t 0 ]]; then
        # clipboard -> stdout
        pbpaste
    else
        # stdin -> clipboard
        pbcopy
    fi
}
