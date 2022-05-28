#!/bin/bash

# Fix virtualenvwrapper

set -euo pipefail

(grep -l '^#!/usr/bin/python3' "$HOME"/.local/bin/* || echo) | xargs -r rm
rm -rf "$HOME"/.local/bin/virtualenvwrapper*
rm -rf "$HOME"/.local/lib/python*
rm -rf "$HOME"/.local/share/virtualenv*
rm -rf "$HOME/.virtualenvs"

curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3
# Bash 3 on Mac missing readarray
# shellcheck disable=SC2207
pip_pkgs=($(grep "^PIP_PKGS=(" "$HOME/.dotfiles/files/bootstrap.sh" | sed "s/^PIP_PKGS=(\(.*\))$/\1/"))
python3 -m pip install --quiet "${pip_pkgs[@]}"
