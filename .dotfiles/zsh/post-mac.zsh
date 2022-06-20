alias ex='nvim -e'
alias rview='nvim -RZ'
alias rvim='nvim -Z'
alias vi='nvim'
alias view='nvim -R'
alias vim='nvim'
alias vimdiff='nvim -d'
alias gvim='vimr'

pidof() {
    ps axc 2> /dev/null | awk "{if (\$5==\"$1\") print \$1}"
}

export FD_COMMAND=fd
