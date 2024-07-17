alias gvim='vimr'

pidof() {
    ps axc 2> /dev/null | awk "{if (\$5==\"$1\") print \$1}"
}

export FD_COMMAND=fd
export K9S_CONFIG_DIR=$HOME/.config/k9s
