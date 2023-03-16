#!/bin/bash

# Set NeoVim as default on Ubuntu

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL https://raw.githubusercontent.com/nevillelyh/dotfiles/main/.dotfiles/files/bs.sh)"
fi

for name in $(update-alternatives --get-selections | grep vim | awk '{print $1}'); do
    readarray -t paths < <(update-alternatives --list "$name" | grep '^/usr/\(bin/nvim\|libexec/neovim[^/]*/\)')
    case "${#paths[@]}" in
        0) bs_error "No alternatives for $name" ;;
        1)
            bs_success "Use ${paths[0]} for $name"
            sudo update-alternatives --set "$name" "${paths[0]}"
            ;;
        *)
            bs_warn "${#paths[@]} alternatives for $name:"
            for path in "${paths[@]}"; do
                bs_warn "    $path"
            done
            ;;
    esac
done
