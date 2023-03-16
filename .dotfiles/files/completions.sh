#!/bin/bash

# Install missing ZSH completions for some packages, e.g. those from Cargo

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <DIR>"
    exit 1
fi

out=$(realpath "$1")
mkdir -p "$out"

tmp=$(mktemp -d)

git clone https://github.com/sharkdp/bat.git "$tmp/bat"
cd "$tmp/bat"
cargo build --release
cp target/release/build/bat-*/out/assets/completions/bat.zsh "$out/_bat"
rm -rf "$tmp"

curl -fsSL https://raw.githubusercontent.com/wfxr/code-minimap/master/completions/zsh/_code-minimap -o "$out/_code-minimap"
curl -fsSL https://github.com/dandavison/delta/blob/master/etc/completion/completion.zsh -o "$out/_delta"
curl -fsSL https://raw.githubusercontent.com/bootandy/dust/master/completions/_dust -o "$out/_dust"
curl -fsSL https://raw.githubusercontent.com/sharkdp/fd/master/contrib/completion/_fd -o "$out/_fd"
curl -fsSL https://github.com/ajeetdsouza/zoxide/blob/main/contrib/completions/_zoxide -o "$out/_zoxide"
