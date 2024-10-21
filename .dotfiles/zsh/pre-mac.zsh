if [[ -z "$TERMINFO_DIRS" ]]; then
    export TERMINFO_DIRS=$HOME/.local/share/terminfo
else
    export TERMINFO_DIRS=$TERMINFO_DIRS:$HOME/.local/share/terminfo
fi

# https://docs.brew.sh/Shell-Completion
FPATH="$FPATH:$(brew --prefix)/share/zsh/site-functions"
