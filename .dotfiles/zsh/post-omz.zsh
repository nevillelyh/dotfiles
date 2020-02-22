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
