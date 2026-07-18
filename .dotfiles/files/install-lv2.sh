#!/bin/sh
set -eu

cd "$(dirname "$0")"

if [ "$(uname -m)" != x86_64 ]; then
    echo "This installer requires Linux x86-64 (x86-64-v3 for Neural Amp Modeler)." >&2
    exit 1
fi

lv2_dir=${LV2_DIR:-"$HOME/.lv2"}
image=neural-amp-modeler-lv2-installer
staging_dir=$(mktemp -d)
trap 'rm -rf "$staging_dir"' EXIT HUP INT TERM

docker build --tag "$image" - <<'EOF'
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libcairo2-dev \
        libx11-dev \
        lv2-dev \
        pkg-config \
        vim-common \
        xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /work \
    && chmod 0777 /work

WORKDIR /work
EOF

docker run --rm \
    --user "$(id -u):$(id -g)" \
    --volume "$PWD:/src:ro" \
    --volume "$staging_dir:/output" \
    "$image" \
    sh -eu -c '
        curl -fsSL \
            https://github.com/mikeoliphant/neural-amp-modeler-lv2/releases/download/v0.2.2/neural_amp_modeler_lv2_linux_x64v3.tgz \
            | tar -xz -C /output

        curl -fsSL \
            https://github.com/brummer10/ImpulseLoader/releases/download/v0.4/ImpulseLoader.lv2-v0.4-linux-x86_64.tar.xz \
            | tar -xJ -C /work
        cp -R /work/ImpulseLoader.lv2-v0.4/ImpulseLoader.lv2 /output/

        cp -R /src /work/neural-amp-modeler-ui
        cd /work/neural-amp-modeler-ui
        git submodule update --init --recursive
        make
        cp -R bin/Neural_Amp_Modeler_ui.lv2/. /output/neural_amp_modeler.lv2/
    '

mkdir -p "$lv2_dir"
rm -rf \
    "$lv2_dir/neural_amp_modeler.lv2" \
    "$lv2_dir/ImpulseLoader.lv2"
cp -R \
    "$staging_dir/neural_amp_modeler.lv2" \
    "$staging_dir/ImpulseLoader.lv2" \
    "$lv2_dir/"

printf 'Installed Neural Amp Modeler v0.2.2 (x86-64-v3), its UI, and ImpulseLoader v0.4 in %s\n' "$lv2_dir"
