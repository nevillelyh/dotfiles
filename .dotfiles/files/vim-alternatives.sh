#!/bin/bash

# Set NeoVim as default on Ubuntu

for name in $(update-alternatives --get-selections | grep vim | awk '{print $1}'); do
    readarray -t paths < <(update-alternatives --list "$name" | grep '^/usr/\(bin/nvim\|libexec/neovim[^/]*/\)')
    case "${#paths[@]}" in
        0) echo "No alternatives for $name" ;;
        1)
            echo "Use ${paths[0]} for $name"
            sudo update-alternatives --set "$name" "${paths[0]}"
            ;;
        *)
            echo "${#paths[@]} alternatives for $name:"
            for path in "${paths[@]}"; do
                echo "    $path"
            done
            ;;
    esac
done
