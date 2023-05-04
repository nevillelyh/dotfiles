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
    eval "$(curl -fsSL https://raw.githubusercontent.com/nevillelyh/dotfiles/main/.dotfiles/files/bs.sh)"
fi

conn=$1
user=""
host=$conn
if echo "$conn" | grep -q '@'; then
    user=$(echo "$conn" | cut -d '@' -f 1)
    host=$(echo "$conn" | cut -d '@' -f 2)
fi

grep -q "Host $host" .ssh/config 2> /dev/null && bs_fatal "Host $host already set up"

bs_info "Sending public key to $host"
key=$(grep signingKey "$HOME/.gitconfig" | grep -o '\<[0-9A-F]\+$')
gpg --export "$key" | ssh "$conn" gpg --import
echo "default-key $key" | ssh "$conn" tee .gnupg/gpg.conf

dst=$(ssh "$conn" gpgconf --list-dir agent-socket)
src=$(gpgconf --list-dir agent-extra-socket)

bs_info "Adding $host to $HOME/.ssh/config"
echo "Host $host" >> "$HOME/.ssh/config"
[[ -z "$user" ]] || echo "    User $user" >> "$HOME/.ssh/config"
cat << EOF >> "$HOME/.ssh/config"
    ForwardAgent yes
    RemoteForward $dst $src
EOF

cat << EOF
Add the following to remote host /etc/ssh/sshd_config:

# https://wiki.gnupg.org/AgentForwarding
StreamLocalBindUnlink yes

And then restart SSH:
sudo systemctl restart ssh.service
EOF
