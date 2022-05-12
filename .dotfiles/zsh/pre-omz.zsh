# Before oh-my-zsh

[[ -d /opt/homebrew/bin ]] && export PATH=/opt/homebrew/bin:$PATH
[[ -d /opt/homebrew/sbin ]] && export PATH=/opt/homebrew/sbin:$PATH
[[ -d $HOME/.local/bin ]] && export PATH=$HOME/.local/bin:$PATH
[[ -s $HOME/.cargo/env ]] && source "$HOME/.cargo/env"

[[ -d /usr/local/go/bin ]] && export PATH=/usr/local/go/bin:$PATH
if type go &> /dev/null; then
    export GOPATH=$HOME/.go
    export PATH=$HOME/.go/bin:$PATH
fi

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

eval $(nvman env)

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
    [[ ! -s "$sfpath/_gh" ]] && gh completion -s zsh > "$sfpath/_gh"
    [[ ! -s "$sfpath/_code-minimap" ]] && code-minimap completion zsh > "$sfpath/_code-minimap"
    [[ ! -s "$sfpath/_zoxide" ]] && zoxide init zsh > "$sfpath/_zoxide"
    autoload -Uz compinit
    compinit
fi
