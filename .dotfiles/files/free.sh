#!/bin/bash

# Free up disk usage

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL https://raw.githubusercontent.com/nevillelyh/dotfiles/main/.dotfiles/files/bs.sh)"
fi

case "$BS_UNAME_S" in
    Darwin)
        bs_info_box "Cleaning up Homebrew cache"
        brew cleanup --prune=all
        ;;
    Linux)
        bs_info_box "Cleaning up APT cache"
        sudo aptitude clean
        ;;
esac

if type docker &> /dev/null; then
    bs_info_box "Cleaning up Docker images"
    docker images --quiet --filter dangling=true | xargs -r docker rmi
    docker volume prune --force
fi

bs_info_box "Cleaning up Go cache"
go clean -modcache

bs_info_box "Cleaning up SDKMAN cache"
rm -f "$HOME"/.sdkman/archives/*.zip

bs_success_box "Clean Up Completed"
