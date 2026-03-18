# Before oh-my-zsh

typeset -aU path

# Reverse order (prepend when present)
bins=(
    # Mac
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

    # Linux
    $HOME/.local/share/JetBrains/Toolbox/scripts
    /snap/bin

    # Common
    $HOME/.go/bin
    $HOME/.krew/bin
    $HOME/.antigravity/antigravity/bin
    $HOME/.local/bin
    $HOME/.dotfiles/bin
)

for b in $bins; do
    [[ -d $b ]] && path=($b $path)
done

brew_bins=(
    /home/linuxbrew/.linuxbrew/bin/brew
    /opt/homebrew/bin/brew
)
for b in $brew_bins; do
    [[ -f $b ]] && eval "$($b shellenv zsh)"
done

path=("$(brew --prefix rustup)/bin" $path)

envs=(
    $HOME/.sdkman/bin/sdkman-init.sh
)

for e in $envs; do
    [[ -s $e ]] && source $e
done

export GOPATH="$HOME/.go"
export SDKMAN_DIR="$HOME/.sdkman"

case "$(uname -s)" in
    Linux)
        # CUDA and cuDNN
        eval "$("$HOME/.dotfiles/bin/nvman" env)"
        ;;
    Darwin)
        export TERMINFO_DIRS="${TERMINFO_DIRS:+$TERMINFO_DIRS:}$HOME/.local/share/terminfo"
        ;;
esac

autoload -Uz compinit
compinit
