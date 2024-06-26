# Workaround for themes relative path
# alias btop='/snap/btop/current/usr/local/bin/btop'

# Compile from source for GPU support
# $HOME/.local/bin/btop
# https://github.com/aristocratos/btop?tab=readme-ov-file#compilation-linux

alias open='xdg-open'
alias xc='xclip -selection clipboard'
alias dgrun='docker run --gpus all --privileged'

FD_COMMAND=fd
# fd is already used by package fdclone on Ubuntu 19.04 or later
if type fdfind &> /dev/null; then
    alias fd='fdfind'
    FD_COMMAND=fdfind
fi
export FD_COMMAND
