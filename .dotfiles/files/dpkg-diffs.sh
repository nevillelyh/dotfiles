#!/bin/bash

# Check changes to local files

set -euo pipefail

url="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/dpkg-diffs/dpkg-diffs-0.1.0.tar.gz"

tmp="$(mktemp -d -t dpkg-diff.XXXXXXXXXX)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "$url" | tar -C "$tmp" -xz
diffs="$(find "$tmp" -type f -name dpkg-diffs | tail -n 1)"

get_packages() {
    echo >&2 "# sudo dpkg -V"
    local dpkgv
    dpkgv="$(sudo dpkg -V || true)"
    local files
    readarray -t files < <(echo "$dpkgv" | cut -c 13-)
    for file in "${files[@]}"; do
        readarray -t pkgs < <(dpkg-query -S "$file" | cut -d ':' -f 1 | sed 's/, /\n/g')
        for pkg in "${pkgs[@]}"; do
            echo >&2 "# $pkg: $file"
            echo "$pkg"
        done
    done | sort -u
}

readarray -t pkgs < <(get_packages)
for pkg in "${pkgs[@]}"; do
    "$diffs" -d "$pkg"
done
