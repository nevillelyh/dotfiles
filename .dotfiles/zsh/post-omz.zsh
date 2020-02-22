# after oh-my-zsh
case "$(uname -s)" in
    Linux)
        . $HOME/.dotfiles/zsh/linux.zsh
        ;;
    Darwin)
        . $HOME/.dotfiles/zsh/mac.zsh
        ;;
esac

alias g='git'
alias vi='vim'
export EDITOR=vim
