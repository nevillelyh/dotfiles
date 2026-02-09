# Before oh-my-zsh

typeset -aU path

# Reverse order (prepend when present)
bins=(
    # Mac
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    "$HOME/Library/Application Support/Coursier/bin"
    /opt/homebrew/sbin
    /opt/homebrew/bin

    # Linux
    $HOME/.local/share/JetBrains/Toolbox/scripts
    $HOME/.swift/usr/bin
    /usr/local/go/bin
    /snap/bin

    # Common
    $HOME/.go/bin
    $HOME/.krew/bin
    $HOME/.antigravity/antigravity/bin
    $HOME/.local/share/coursier/bin
    $HOME/.local/bin
    $HOME/.dotfiles/bin
)

for b in $bins; do
    [[ -d $b ]] && path=($b $path)
done

envs=(
    $HOME/.cargo/env
    $HOME/.local/share/swiftly/env.sh
    $HOME/.sdkman/bin/sdkman-init.sh
)

for e in $envs; do
    [[ -s $e ]] && source $e
done

export GOPATH="$HOME/.go"
export SDKMAN_DIR="$HOME/.sdkman"

FPATH="$HOME/.local/share/zsh/site-functions:$FPATH"
autoload -Uz compinit
compinit

case "$(uname -s)" in
    Linux)
        source "$HOME/.dotfiles/zsh/pre-linux.zsh"
        ;;
    Darwin)
        source "$HOME/.dotfiles/zsh/pre-mac.zsh"
        ;;
esac
