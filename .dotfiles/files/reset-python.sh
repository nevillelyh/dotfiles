#!/bin/bash

# Reset local Python environment

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL https://raw.githubusercontent.com/nevillelyh/dotfiles/main/.dotfiles/files/bs.sh)"
fi

case "$BS_UNAME_S" in
    Darwin)
        shebang='^#!/opt/homebrew/opt/python@'
        prefix=/opt/homebrew
        ;;
    Linux)
        shebang='^#!/usr/bin/python3'
        prefix="$HOME/.local"
        ;;
esac

(grep -l "$shebang" "$prefix/bin/"* || echo) | xargs -r rm
rm -rf "$prefix"/bin/virtualenvwrapper*
rm -rf "$prefix"/lib/python*
rm -rf "$prefix"/share/virtualenv*
rm -rf "$HOME/.virtualenvs"

curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3
# Bash 3 on Mac missing readarray
# shellcheck disable=SC2207
pip_pkgs=($(grep '^PIP_PKGS=(' "$HOME/.dotfiles/files/bootstrap.sh" | sed 's/^PIP_PKGS=(\(.*\))$/\1/'))
python3 -m pip install "${pip_pkgs[@]}"
