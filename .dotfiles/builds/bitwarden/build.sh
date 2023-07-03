#!/bin/bash

set -euo pipefail

cli_version=2023.5.0
desktop_version=2023.5.1

run_guest() {
    apt update
    apt upgrade -y
    apt install -y git

    git clone https://github.com/bitwarden/clients.git

    cd /clients
    git checkout "cli-v$cli_version"
    npm ci
    cd apps/cli
    sed -i 's/linux-x64/linux-arm64/g' package.json
    npm run dist:lin
    git reset --hard

    cd /clients
    git checkout "desktop-v$desktop_version"
    npm ci
    cd apps/desktop
    sed -i 's/--linux --x64/--linux --arm64/g' package.json
    sed -i 's/"target": \[\(.*"AppImage".*\)],/"target": ["AppImage"],/g' electron-builder.json
    npm run dist:lin
    git reset --hard
}

run_host() {
    base="$(readlink -f "$0")"
    docker run --name bitwarden --volume "$base":/build.sh node:18 /build.sh
    docker cp bitwarden:/clients/apps/cli/dist/linux/bw .
    docker cp "bitwarden:/clients/apps/desktop/dist/Bitwarden-$desktop_version-arm64.AppImage" .
}

if [[ -f /.dockerenv ]]; then
    run_guest
else
    run_host
fi
