if [[ -d "$HOME/.swift" ]]; then
    export TOOLCHAINS="$HOME/.swift"
fi

# CUDA and cuDNN
eval "$("$HOME/.dotfiles/bin/nvman" env)"
