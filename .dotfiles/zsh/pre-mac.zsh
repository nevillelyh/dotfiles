export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts":$PATH

[[ -d /opt/homebrew/bin ]] && export PATH=/opt/homebrew/bin:$PATH
[[ -d /opt/homebrew/sbin ]] && export PATH=/opt/homebrew/sbin:$PATH

# https://docs.brew.sh/Shell-Completion
FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
