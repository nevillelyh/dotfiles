alias vi='nvim'
alias vim='nvim'
alias gvim='vimr'

pidof() {
    ps axc 2>/dev/null | awk "{if (\$5==\"$1\") print \$1}"
}

export FD_COMMAND=fd
