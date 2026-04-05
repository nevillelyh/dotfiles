alias open='xdg-open'
alias dgrun='docker run --gpus all --privileged'

# Linux Homebrew installs these commands without setuid, override them
# find /usr/bin -maxdepth 1 -perm -4000 -printf '%f\n' 2>/dev/null |
# while IFS= read -r b; do
#   if [[ -L "/home/linuxbrew/.linuxbrew/bin/$b" ]]; then
#     echo "alias $b=/usr/bin/$b"
#   fi
# done
alias mount=/usr/bin/mount
alias umount=/usr/bin/umount

# copy/paste
xc() {
    if [[ -t 0 ]]; then
        # clipboard -> stdout
        wl-paste
    else
        # stdin -> clipboard
        wl-copy
    fi
}
