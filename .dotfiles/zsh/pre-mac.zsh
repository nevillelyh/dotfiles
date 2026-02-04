export TERMINFO_DIRS="${TERMINFO_DIRS:+$TERMINFO_DIRS:}$HOME/.local/share/terminfo"

# https://docs.brew.sh/Shell-Completion
FPATH="$FPATH:$(brew --prefix)/share/zsh/site-functions"
