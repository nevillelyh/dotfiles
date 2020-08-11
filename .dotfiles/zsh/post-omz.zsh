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

function zt() {
    z $1
    ts $1
}

export EDITOR=nvim

if [[ -n $(pidof ssh-agent) ]]; then
    ssh-add $HOME/.ssh/private/id_rsa $HOME/.ssh/spotify/id_rsa > /dev/null 2>&1
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

if [[ -n $CLOUDSDK_HOME ]]; then
    alias gscat='gsutil cat'
    alias gsdu='gsutil du'
    alias gsls='gsutil ls'
    alias gscp='gsutil -m cp'
    alias gsmv='gsutil -m mv'
    alias gsrm='gsutil -m rm'
fi

source "$HOME/.cargo/env"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
