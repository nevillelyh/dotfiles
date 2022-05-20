# After oh-my-zsh

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
alias ghpr='gh pr create --fill'
alias l='exa -la' # 'ls -lah'
alias la='exa -la' # 'ls -lAh'
alias ll='exa -l' # 'ls -lh'
alias ls='exa' # 'ls -G'
alias lsa='exa -la' # 'ls -lah'
alias lsg='exa -l --git'
alias lst='exa -l -r -s modified'

function zt() {
    z $1
    tmux new-session -s $1
}

export EDITOR=nvim
export FZF_DEFAULT_COMMAND="$FD_COMMAND --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
unset FD_COMMAND
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,hl:#bd93f9 --color=fg+:#f8f8f2,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

if type virtualenvwrapper.sh &> /dev/null; then
    export VIRTUALENVWRAPPER_PYTHON=$(which python3)
    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/src/python
    source $(which virtualenvwrapper.sh)
fi

# conda activate base
if [[ -d $HOME/.anaconda3/condabin ]]; then
    cache=$HOME/.cache/anaconda3.zsh
    [[ -s $cache ]] || $HOME/.anaconda3/condabin/conda shell.zsh hook > $cache
    source $cache
fi

# Reuse a single SSH agent
if [[ -z "$SSH_CONNECTION" ]]; then
    agent=/tmp/ssh-agent-tmux-$USER
    if [[ -z $(pidof ssh-agent) ]]; then
        eval $(ssh-agent) &> /dev/null
        ssh-add -q $(find $HOME/.ssh -name id_dsa -or -name id_rsa -or -name id_ecdsa -or -name id_ed25519)
        [[ "$SSH_AUTH_SOCK" != "$agent" ]] && ln -fs "$SSH_AUTH_SOCK" "$agent"
    fi
    export SSH_AUTH_SOCK="$agent"
    unset agent
fi

# Deduplicate $PATH
typeset -aU path
