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
alias ghpr='gh pr create'

# Docker
alias digc='docker images --quiet --filter dangling=true | xargs -r docker rmi'
alias dcgc='docker ps --all --filter "status=exited" --quiet | xargs -r docker rm'
alias dka='docker ps --quiet | xargs -r docker kill'
alias darch='docker images --quiet | xargs docker inspect |jq -r ".[]|.Architecture+\"\t\"+(.RepoTags|join(\",\"))"'

# exa
alias l='exa -la' # 'ls -lah'
alias la='exa -la' # 'ls -lAh'
alias ll='exa -l' # 'ls -lh'
alias ls='exa' # 'ls -G'
alias lsa='exa -la' # 'ls -lah'
alias lsg='exa -l --git'
alias lst='exa -l -r -s modified'

# gsutil
alias gscat='gsutil cat'
alias gscp='gsutil -m cp'
alias gsdu='gsutil du'
alias gsls='gsutil ls'
alias gsmv='gsutil -m mv'
alias gsrm='gsutil -m rm'

function rg() {
    command rg --json "$@" | delta
}

if [[ -L /opt/homebrew/bin/mvnd ]] || [[ -d "$HOME/.sdkman/candidates/mvnd" ]]; then
    unalias mvnd
fi

function zt() {
    session="$1"
    if tmux has-session -t "$session" &> /dev/null; then
        tmux attach -d -t "$session"
    else
        z "$1" && tmux new-session -s "$session"
    fi
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
ssh_keys=("${(@f)$(find "$HOME/.ssh" \( -name id_dsa -or -name id_rsa -or -name id_ecdsa -or -name id_ed25519 \))}")
if [[ -n "$ssh_keys" ]]; then
    agent=/tmp/ssh-agent-tmux-$USER
    if [[ -z $(pidof ssh-agent) ]] || [[ ! -e "$agent" ]]; then
        eval "$(ssh-agent)" &> /dev/null
        ssh-add -q "${ssh_keys[@]}"
        ln -fs "$SSH_AUTH_SOCK" "$agent"
    fi
    export SSH_AUTH_SOCK="$agent"
    unset agent
fi
unset ssh_keys

if [[ -d $HOME/.dotfiles/private/profile.d ]]; then
    for f in $HOME/.dotfiles/private/profile.d/*.sh; do
        source $f
    done
fi

# BitWarden

bw-unlock() {
    case "$(bw status | jq --raw-output ".status")" in
        unauthenticated)
            local email
            email="$(git config --get user.email)"
            BW_SESSION=$(bw login "$email" --raw)
            export BW_SESSION
            ;;
        locked)
            BW_SESSION=$(bw unlock --raw)
            export BW_SESSION
            ;;
        *) ;;
    esac
}

alias bwst="bw status"
alias bws="bw sync"
alias bwgu="bw-unlock && bw get username"
alias bwgp="bw-unlock && bw get password"
alias bwgt="bw-unlock && bw get totp"

bwg() {
    bw-unlock && bw get item "$@" | jq --raw-output ".login.username,.login.password" && bwgt "$@"
}

bwgi() {
    bw-unlock && bw get item "$@" | jq
}

bwf() {
    bw-unlock && bw list items --search "$@" | jq
}

# Deduplicate $PATH
typeset -aU path

# For Docker
# https://github.com/docker/compose/issues/2380
export UID
export GID
