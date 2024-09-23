# https://superuser.com/a/583502
#
# ZSH start up files:
# - /etc/zsh/zshenv
# - $HOME/.zshenv
# - login shell: /etc/zsh/zprofile, $HOME/.zprofile
# - interactive shell: /etc/zsh/zshrc, $HOME/.zshrc
#
# Environment specific:
# - Linux: /etc/zsh/zshenv sets PATH
# - Mac: /etc/zprofile calls /usr/libexec/path_helper to prepend PATH
# - Terminal on Linux: interactive
# - Terminal on Mac: login & interactive
# - tmux: login & interactive
# - SSH: login & interactive

if [[ -o interactive ]] || [[ -o login ]]; then
    # Deactivate venv
    if ! [ -z "${_OLD_VIRTUAL_PS1+_}" ]; then
            PS1="$_OLD_VIRTUAL_PS1"
            export PS1
            unset _OLD_VIRTUAL_PS1
    fi
    unset VIRTUAL_ENV
    unset VIRTUAL_ENV_PROMPT

    if [[ -o login ]] && [[ -x /usr/libexec/path_helper ]]; then
        unset PATH # Let path_helper regenerate
    else
        export PATH="/usr/local/bin:/usr/bin:/bin"
    fi
fi
