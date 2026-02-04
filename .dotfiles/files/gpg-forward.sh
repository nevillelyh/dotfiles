#!/bin/bash

# Set up a host for GPG agent forwarding

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <HOST>"
    exit 1
fi

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL bit.ly/bs-dot-sh)"
fi

conn=$1
host=${conn#*@}

bs_info "Sending public key to $host"
key=$(grep -E 'signingKey' "$HOME/.gitconfig" | grep -oE '[0-9A-F]+$')
gpg --export "$key" | ssh "$conn" gpg --import
echo "default-key $key" | ssh "$conn" tee .gnupg/gpg.conf

dst=$(ssh "$conn" gpgconf --list-dir agent-socket)
src=$(gpgconf --list-dir agent-extra-socket)
cat << EOF
Add the following to $HOME/.ssh/config

RemoteForward $dst $src

Add the following to remote host /etc/ssh/sshd_config.d/gpg.conf:

# https://wiki.gnupg.org/AgentForwarding
StreamLocalBindUnlink yes

And then restart SSH:
sudo systemctl restart ssh.service
EOF
