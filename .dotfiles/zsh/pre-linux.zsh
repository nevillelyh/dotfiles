export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts":$PATH

[[ -d /snap/bin ]] && export PATH=/snap/bin:$PATH
[[ -d /usr/local/go/bin ]] && export PATH=/usr/local/go/bin:$PATH
if [[ -d "$HOME/.swift" ]]; then
    export TOOLCHAINS="$HOME/.swift"
    export PATH="$HOME/.swift/usr/bin:$PATH"
fi

# CUDA and cuDNN
eval "$($HOME/.dotfiles/bin/nvman env)"

# Some Linux packages have no bundled completion
# https://cli.github.com/manual/gh_completion
local sfpath="$HOME/.local/share/zsh/site-functions"

[[ -d "$sfpath" ]] || mkdir -p "$sfpath"

mk_comp() {
    cmd=$1
    shift
    type "$cmd" &> /dev/null && [[ ! -s "$sfpath/_$cmd" ]] && "$cmd" "$@" > "$sfpath/_$cmd"
}

mk_comp zoxide init zsh
