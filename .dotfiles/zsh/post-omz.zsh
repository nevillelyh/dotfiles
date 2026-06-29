# After oh-my-zsh

case "$(uname -s)" in
    Linux)
        source "$HOME/.dotfiles/zsh/post-linux.zsh"
        ;;
    Darwin)
        source "$HOME/.dotfiles/zsh/post-mac.zsh"
        ;;
esac

# Command line utilities
alias cat='bat'
alias diff='colordiff'
alias ghpr='gh pr create'
alias kx=kubectx

# Docker
alias digc='docker images --quiet --filter dangling=true | while IFS= read -r image; do docker rmi "$image"; done'
alias dcgc='docker ps --all --filter "status=exited" --quiet | while IFS= read -r container; do docker rm "$container"; done'
alias dka='docker ps --quiet | while IFS= read -r container; do docker kill "$container"; done'
alias drma='docker ps --all --quiet | while IFS= read -r container; do docker rm "$container"; done'
alias darch="docker images --quiet | while IFS= read -r image; do docker inspect \"\$image\"; done | jq -r '.[]|.Architecture+\"\\t\"+(.RepoTags|join(\",\"))'"

# eza
alias l='eza -la' # 'ls -lah'
alias la='eza -la' # 'ls -lAh'
alias ll='eza -l' # 'ls -lh'
alias ls='eza' # 'ls -G'
alias lsa='eza -la' # 'ls -lah'
alias lsg='eza -l --git'
alias lst='eza -l -r -s modified'

# FZF
export FZF_DEFAULT_COMMAND="fd --type f"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,hl:#bd93f9 --color=fg+:#f8f8f2,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
export FZF_CTRL_T_OPTS='--bind "alt-p:toggle-preview" --multi --preview="bat --style=plain --color=always {}" --preview-window=60%'

# Git
alias gpp='git pull-prune'

# gsutil
alias gscat='gsutil cat'
alias gscp='gsutil -m cp'
alias gsdu='gsutil du'
alias gsls='gsutil ls'
alias gsmv='gsutil -m mv'
alias gsrm='gsutil -m rm'

# NeoVim
export EDITOR=nvim
alias ex='nvim -e'
alias rview='nvim -RZ'
alias rvim='nvim -Z'
alias vi='nvim'
alias view='nvim -R'
alias vim='nvim'
alias vimdiff='nvim -d'

# uv
export UV_CONFIG_FILE="$HOME/.config/uv/uv.toml"

# fnm
[[ ! -d "$HOME/.local/share/fnm" ]] || eval "$(fnm env --use-on-cd --shell zsh)"


# Functions

function rg() {
    command rg --json "$@" | delta
}

# Jump to a directory and start or attach a tmux session
function zt() {
    local session=$1
    if tmux has-session -t "$session" &> /dev/null; then
        tmux attach -d -t "$session"
    else
        z "$session" && tmux new-session -s "$session"
    fi
}

# Jump to main git directory
function zgm() {
    cd -- "$(git rev-parse --path-format=absolute --git-common-dir | sed 's#/.git$##')"
}

# Jump to a git worktree
function zg() {
    local q="${1:-}"
    local wt hash branch shown line selected target
    local -a rows

    while read -r wt hash branch; do
        shown="${wt/#$HOME/~}"
        line="$shown $hash $branch"

        [[ -z "$q" || "$line" == *"$q"* ]] && rows+=("$line")
    done < <(git worktree list)

    if (( ${#rows[@]} == 0 )); then
        local d="$(git rev-parse --path-format=absolute --git-common-dir | sed 's#/.git$##')"
        if [[ -n "$2" ]] && ! git rev-parse --verify --quiet "$2^{commit}" >/dev/null; then
            git worktree add -b "$2" "$d/.worktrees/$q"
        else
            git worktree add "$d/.worktrees/$q" ${2:+"$2"}
        fi
        selected="$d/.worktrees/$q"
    elif (( ${#rows[@]} == 1 )); then
        selected="${rows[1]}"
    else
        selected="$(printf '%s\n' "${rows[@]}" | fzf --query="$q")" || return
    fi

    target="${selected%% *}"
    target="${target/#\~/$HOME}"

    cd -- "$target" || return
}

# Reuse a single SSH agent
ssh_keys=("$HOME/.ssh"/**/id_{dsa,rsa,ecdsa,ed25519}(N))
if (( ${#ssh_keys[@]} )); then
    agent="/tmp/ssh-agent-tmux-$USER"
    if ! pidof ssh-agent &> /dev/null || [[ ! -e $agent ]]; then
        eval "$(ssh-agent)" &> /dev/null
        ssh-add -q -- "${ssh_keys[@]}"
        ln -fs -- "$SSH_AUTH_SOCK" "$agent"
    fi
    export SSH_AUTH_SOCK="$agent"
    unset agent
fi
unset ssh_keys

# Private environment
for f in "$HOME"/.dotfiles/private/profile.d/*.sh(N); do
    source "$f"
done

# BitWarden

bw-unlock() {
    local status
    status="$(bw status | jq --raw-output ".status")"
    case "$status" in
        unauthenticated)
            local email
            email="$(git config --get user.email)"
            BW_SESSION="$(bw login "$email" --raw)"
            export BW_SESSION
            ;;
        locked)
            BW_SESSION="$(bw unlock --raw)"
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

# For Docker
# https://github.com/docker/compose/issues/2380
export UID
export GID
