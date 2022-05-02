#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: gpg_forward.sh <host>"
    exit
fi

HOST=$1

if grep -q "Host $HOST" .ssh/config; then
    echo "Host $HOST already set up"
    exit
fi

echo "Sending public key to $HOST"
gpg --export $(grep signingkey $HOME/.gitconfig | grep -o '[0-9A-F]\+') | ssh $HOST gpg --import

DST=$(gpgconf --list-dir agent-socket)
SRC=$(gpgconf --list-dir agent-extra-socket)

echo "Adding $HOST to ~/.ssh/config"
cat << EOF >> ~/.ssh/config
Host $HOST
    ForwardAgent yes
    RemoteForward $DST $SRC
EOF

cat << EOF
Add the following to remote host /etc/ssh/sshd_config:

# https://wiki.gnupg.org/AgentForwarding
StreamLocalBindUnlink yes

And then restart SSH:
sudo systemctl restart ssh.service
EOF
