# https://superuser.com/a/583502
# Mac /etc/zprofile calls path_helper which prepends $PATH
# Unset it in tmux to rebuild PATH from scratch
[[ -n "$TMUX" ]] && [[ -x /usr/libexec/path_helper ]] && unset PATH
