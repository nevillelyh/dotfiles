#!/bin/bash

# Tests for bs.sh

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL bit.ly/bs-dot-sh)"
fi

if [[ $# -eq 1 ]] && [[ "$1" == "ping" ]]; then
    echo "pong"
elif [[ $# -gt 0 ]]; then
    "$@"
else
    _bs_test
fi
