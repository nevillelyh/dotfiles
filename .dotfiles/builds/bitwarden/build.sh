#!/bin/bash

set -euo pipefail

cli_version=2023.5.0

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
}

run_host() {
    base="$(readlink -f "$0")"
    docker run --name bitwarden --volume "$base":/build.sh node:18 /build.sh
    docker cp bitwarden:/clients/apps/cli/dist/linux/bw .
}

if [[ -f /.dockerenv ]]; then
    run_guest
else
    run_host
fi
