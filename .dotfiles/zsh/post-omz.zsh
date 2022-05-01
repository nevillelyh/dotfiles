# after oh-my-zsh
case "$(uname -s)" in
    Linux)
        . $HOME/.dotfiles/zsh/linux.zsh
        ;;
    Darwin)
        . $HOME/.dotfiles/zsh/mac.zsh
        ;;
esac

alias cat='bat'
alias diff='colordiff'
alias l='exa -la' # 'ls -lah'
alias la='exa -la' # 'ls -lAh'
alias ll='exa -l' # 'ls -lh'
alias ls='exa' # 'ls -G'
alias lsa='exa -la' # 'ls -lah'
alias lsg='exa -l --git'
alias lst='exa -l -r -s modified'

function zt() {
    z $1
    ts $1
}

export EDITOR=nvim

# reuse a single SSH agent
if [ -z "$SSH_CONNECTION" ]; then
    AGENT=/tmp/ssh-agent-tmux-$USER
    if [[ -z $(pidof ssh-agent) ]]; then
        eval $(ssh-agent) > /dev/null 2>&1
        ssh-add -q $(find $HOME/.ssh -name id_dsa -or -name id_rsa)
        [[ "$SSH_AUTH_SOCK" != "$AGENT" ]] && ln -sf "$SSH_AUTH_SOCK" "$AGENT"
    fi
    export SSH_AUTH_SOCK="$AGENT"
    unset AGENT
fi

export FZF_DEFAULT_COMMAND="$FD_COMMAND --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
unset FD_COMMAND

if type virtualenvwrapper.sh >/dev/null 2>&1; then
    export VIRTUALENVWRAPPER_PYTHON=$(which python3)
    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/src/python
    source $(which virtualenvwrapper.sh)
fi

source "$HOME/.cargo/env"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


# Deduplicate $PATH
typeset -aU path
