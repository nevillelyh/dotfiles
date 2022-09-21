# After oh-my-zsh

case "$(uname -s)" in
    Linux)
        . "$HOME/.dotfiles/zsh/post-linux.zsh"
        ;;
    Darwin)
        . "$HOME/.dotfiles/zsh/post-mac.zsh"
        ;;
esac

alias cat='bat'
alias diff='colordiff'
alias digc='docker images --quiet --filter dangling=true | xargs -r docker rmi'
alias ghpr='gh pr create'
alias l='exa -la' # 'ls -lah'
alias la='exa -la' # 'ls -lAh'
alias ll='exa -l' # 'ls -lh'
alias ls='exa' # 'ls -G'
alias lsa='exa -la' # 'ls -lah'
alias lsg='exa -l --git'
alias lst='exa -l -r -s modified'
alias gscat='gsutil cat'
alias gscp='gsutil -m cp'
alias gsdu='gsutil du'
alias gsls='gsutil ls'
alias gsmv='gsutil -m mv'
alias gsrm='gsutil -m rm'

if [[ -L /opt/homebrew/bin/mvnd ]] || [[ -d "$HOME/.sdkman/candidates/mvnd" ]]; then
    unalias mvnd
fi

function zt() {
    z "$1" && tmux new-session -s "$1"
}

export EDITOR=nvim
export FZF_DEFAULT_COMMAND="$FD_COMMAND --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
unset FD_COMMAND
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,hl:#bd93f9 --color=fg+:#f8f8f2,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

if type virtualenvwrapper.sh &> /dev/null; then
    export VIRTUALENVWRAPPER_PYTHON=$(which python3)
    export WORKON_HOME=$HOME/.virtualenvs
    source $(which virtualenvwrapper.sh)
fi

# Using system Python by default, base is not activated
# conda activate base
# conda config --set auto_activate_base false
condabin=("$HOME/.anaconda3/condabin/conda" /opt/homebrew/anaconda3/condabin/conda)
for cb in "${condabin[@]}"; do
    if [[ -x "$cb" ]]; then
        # Delete cache after conda config
        cache=$HOME/.cache/anaconda3.zsh
        [[ -s "$cache" ]] || "$cb" shell.zsh hook > "$cache"
        source "$cache"
        break
    fi
done

# Reuse a single SSH agent
if [[ -z "$SSH_CONNECTION" ]]; then
    agent=/tmp/ssh-agent-tmux-$USER
    if [[ -z $(pidof ssh-agent) ]]; then
        eval "$(ssh-agent)" &> /dev/null
        find "$HOME/.ssh" \( -name id_dsa -or -name id_rsa -or -name id_ecdsa -or -name id_ed25519 \) \
            -exec ssh-add -q {} \;
        [[ "$SSH_AUTH_SOCK" != "$agent" ]] && ln -fs "$SSH_AUTH_SOCK" "$agent"
    fi
    export SSH_AUTH_SOCK="$agent"
    unset agent
fi

if [[ -d $HOME/.local/etc/profile.d ]]; then
    for f in $HOME/.local/etc/profile.d/*.sh; do
        source $f
    done
fi

# Deduplicate $PATH
typeset -aU path
