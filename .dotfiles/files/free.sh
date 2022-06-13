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

docker images --quiet --filter dangling=true | xargs -r docker rmi
docker volume prune --force
