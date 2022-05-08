#!/bin/bash

# Set NeoVim as default on Ubuntu

for name in $(update-alternatives --get-selections | grep vim | awk '{print $1}'); do
    sudo update-alternatives --config $name
done
