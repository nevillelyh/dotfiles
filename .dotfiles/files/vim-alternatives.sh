#!/bin/bash

# Set NeoVim as default on Ubuntu

for name in $(update-alternatives --get-selections | grep vim | awk '{print $1}'); do
    if ! update-alternatives --list "$name" | grep -q "/usr/bin/nvim"; then
        sudo update-alternatives --install "/usr/bin/$name" "$name" /usr/bin/nvim 100
    fi
    sudo update-alternatives --config "$name"
done
