# Before oh-my-zsh

case "$(uname -s)" in
    Linux)
        . "$HOME/.dotfiles/zsh/pre-linux.zsh"
        ;;
    Darwin)
        . "$HOME/.dotfiles/zsh/pre-mac.zsh"
        ;;
esac

# Reverse order
bins=(
    # Mac
    $HOME/Library/Application Support/JetBrains/Toolbox/scripts
    /opt/homebrew/sbin
    /opt/homebrew/bin

    # Linux
    $HOME/.local/share/JetBrains/Toolbox/scripts
    $HOME/.swift/usr/bin
    /usr/local/go/bin
    /snap/bin

    # Common
    $HOME/.go/bin
    $HOME/.local/share/coursier/bin
    $HOME/.local/bin
    $HOME/.dotfiles/bin
)

for b in ${bins}; do
    [[ -d "$b" ]] && export PATH=$b:$PATH
done

[[ -s $HOME/.cargo/env ]] && source "$HOME/.cargo/env"

export GOPATH=$HOME/.go
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

FPATH="$HOME/.local/share/zsh/site-functions:$FPATH"
autoload -Uz compinit
compinit
