#!/bin/bash

# Free up disk usage

set -euo pipefail

case "$(uname -s)" in
    Darwin)
        brew cleanup --prune=all
        ;;
    Linux)
        sudo aptitude clean
        ;;
esac

if type docker &> /dev/null; then
    docker images --quiet --filter dangling=true | xargs -r docker rmi
    docker volume prune --force
fi

go clean -modcache

rm -f "$HOME"/.sdkman/archives/*.zip
