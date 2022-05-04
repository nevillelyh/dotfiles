#!/bin/bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename $0) <HOST>"
    exit 1
fi

host=$1

if grep -q "Host $host" .ssh/config 2> /dev/null; then
    echo "Host $host already set up"
    exit 1
fi

echo "Sending public key to $host"
gpg --export $(grep signingkey $HOME/.gitconfig | grep -o '[0-9A-F]\+') | ssh $host gpg --import

dst=$(ssh $host gpgconf --list-dir agent-socket)
src=$(gpgconf --list-dir agent-extra-socket)

echo "Adding $host to ~/.ssh/config"
cat << EOF >> ~/.ssh/config
Host $host
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
