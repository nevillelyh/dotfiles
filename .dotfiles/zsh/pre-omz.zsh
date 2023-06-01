# Before oh-my-zsh

case "$(uname -s)" in
    Linux)
        . "$HOME/.dotfiles/zsh/pre-linux.zsh"
        ;;
    Darwin)
        . "$HOME/.dotfiles/zsh/pre-mac.zsh"
        ;;
esac

[[ -d $HOME/.local/bin ]] && export PATH=$HOME/.local/bin:$PATH
[[ -s $HOME/.cargo/env ]] && source "$HOME/.cargo/env"

if type go &> /dev/null; then
    export GOPATH=$HOME/.go
    export PATH=$HOME/.go/bin:$PATH
fi

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH=$HOME/.dotfiles/bin:$PATH

FPATH="$HOME/.local/share/zsh/site-functions:$FPATH"
autoload -Uz compinit
compinit
