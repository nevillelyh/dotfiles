# after oh-my-zsh
case "$(uname -s)" in
    Linux)
        . $HOME/.dotfiles/zsh/linux.zsh
        ;;
    Darwin)
        . $HOME/.dotfiles/zsh/mac.zsh
        ;;
esac

# covered by oh-my-zsh plugin
# aliasing to 'hub' breaks completion
# alias g='git'

# covered by /etc/alternatives
# alias vi='vim'

export EDITOR=vim

if [ -f $HOME/.local/bin/virtualenvwrapper.sh ]; then
    export VIRTUALENVWRAPPER_PYTHON=$(which python3)
    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/src/python
    source $HOME/.local/bin/virtualenvwrapper.sh
fi
