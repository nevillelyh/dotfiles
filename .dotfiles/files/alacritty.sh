#!/usr/bin/env bash

set -euo pipefail
if [ $# -gt 1 ]; then
    echo "Usage: $0 [version]"
    exit 1
fi

repo=$(mktemp -d)
trap 'rm -rf "$repo"' EXIT

git clone --quiet https://github.com/alacritty/alacritty.git "$repo"
cd "$repo"

version=${1:-}
if [[ -z "$version" ]]; then
    while IFS= read -r tag; do
        if [[ "$tag" =~ ^v[0-9]+(\.[0-9]+)+$ ]]; then
            version=$tag
            break
        fi
    done < <(git tag --list --sort=-v:refname)
fi
git checkout --quiet --detach "$version"

# https://github.com/alacritty/alacritty/blob/master/INSTALL.md
case "$(uname -s)" in
    Darwin)
        make clean app
        mv target/release/osx/Alacritty.app /Applications
        ;;
    Linux)
        docker run --rm \
            --env HOST_GID="$(id -g)" \
            --env HOST_UID="$(id -u)" \
            --volume "$repo:/src" \
            --workdir /src \
            rust:bookworm \
            bash -c '
                cleanup() {
                    chown -R "$HOST_UID:$HOST_GID" target 2>/dev/null || true
                }
                trap cleanup EXIT
                apt-get update &&
                apt-get install -y \
                    cmake \
                    g++ \
                    libfontconfig1-dev \
                    libxcb-xfixes0-dev \
                    libxkbcommon-dev \
                    pkg-config \
                    python3 &&
                cargo build --release
            '
        sudo cp target/release/alacritty /usr/local/bin
        sudo install -Dm644 extra/logo/alacritty-term.svg /usr/local/share/icons/hicolor/scalable/apps/Alacritty.svg
        sudo install -Dm644 extra/linux/Alacritty.desktop /usr/local/share/applications/Alacritty.desktop
        ;;
esac

sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
