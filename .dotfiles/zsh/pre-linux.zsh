export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts":$PATH

[[ -d /snap/bin ]] && export PATH=/snap/bin:$PATH
[[ -d /usr/local/go/bin ]] && export PATH=/usr/local/go/bin:$PATH
if [[ -d "$HOME/.swift" ]]; then
    export TOOLCHAINS="$HOME/.swift"
    export PATH="$HOME/.swift/usr/bin:$PATH"
fi

# CUDA and cuDNN
eval "$($HOME/.dotfiles/bin/nvman env)"
