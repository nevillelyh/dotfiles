#!/bin/bash

# Free up disk usage

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL https://raw.githubusercontent.com/nevillelyh/dotfiles/main/.dotfiles/files/bs.sh)"
fi

find_delete() {
    local dir=$1
    local size
    size="$(find "$@" -print0 | xargs -0 du -hcs | tail -n 1 | awk '{print $1}')"
    [[ -z "$size" ]] && size="0B"
    printf "%s\t%s\n" "$size" "$dir"
    find "$@" -delete
}

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

bs_info_box "Cleaning up Maven cache"
dirs=(.cache/coursier .gradle/caches .ivy/cache .m2/repository Library/Caches/Coursier)
for dir in "${dirs[@]}"; do
    if [[ -d "$HOME/$dir" ]]; then
        find_delete "$HOME/$dir" -type f -name "*-SNAPSHOT.*" -atime +30
    fi
done

bs_info_box "Cleaning up SDKMAN cache"
find_delete "$HOME/.sdkman/tmp" \( -name "*.zip" -or -name "*.tmp" \)

bs_success_box "Clean Up Completed"
