# Before oh-my-zsh

[[ -d /snap/bin ]] && export PATH=/snap/bin:$PATH
[[ -d /opt/homebrew/bin ]] && export PATH=/opt/homebrew/bin:$PATH
[[ -d /opt/homebrew/sbin ]] && export PATH=/opt/homebrew/sbin:$PATH
[[ -d $HOME/.local/bin ]] && export PATH=$HOME/.local/bin:$PATH
[[ -s $HOME/.cargo/env ]] && source "$HOME/.cargo/env"

[[ -d /usr/local/go/bin ]] && export PATH=/usr/local/go/bin:$PATH
if type go &> /dev/null; then
    export GOPATH=$HOME/.go
    export PATH=$HOME/.go/bin:$PATH
fi

# CUDA and cuDNN
eval "$(nvman env)"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# https://docs.brew.sh/Shell-Completion
if type brew &> /dev/null; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"

    autoload -Uz compinit
    compinit
else
    # Some Linux packages have no bundled completion
    # https://cli.github.com/manual/gh_completion
    local sfpath="$HOME/.local/share/zsh/site-functions"
    FPATH="$sfpath:$FPATH"

    [[ ! -d "$sfpath" ]] && mkdir -p "$sfpath"

    mk_comp() {
        cmd=$1
        shift
        type "$cmd" &> /dev/null && [[ ! -s "$sfpath/_$cmd" ]] && "$cmd" "$@" > "$sfpath/_$cmd"
    }
    mk_comp gh completion -s zsh
    mk_comp code-minimap completion zsh
    mk_comp helm completion zsh
    mk_comp kubectl completion zsh
    mk_comp minikube completion zsh
    mk_comp zoxide init zsh

    autoload -Uz compinit
    compinit
fi
