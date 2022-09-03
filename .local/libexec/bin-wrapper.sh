#!/bin/bash

set -euo pipefail

libexec="$HOME/.local/libexec"

links() {
    url=$1
    curl -fsSL "$url" | grep -o 'href="[^"]\+"' | sed 's/href="\([^"]*\)"/\1/'
}

update() {
    (( ttl = 7 * 24 * 60 * 60 ))
    (( age = ttl + 1 ))
    [[ -f "$bin" ]] && age=$(echo "$(date "+%s")" - "$(date -r "$bin" "+%s")" | bc -l)
    if [[ $age -ge $ttl ]]; then
        download
    fi
}

run_b2() {
    download() {
        os=$(uname -s | tr "[:upper:]" "[:lower:]")
        url="https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-$os"
        curl -fsSL "$url" -o "$bin"
        chmod +x "$bin"
    }
    bin="$libexec/b2"
    update
    "$bin" "$@"
}

run_bazel() {
    download() {
        os=$(uname -s | tr "[:upper:]" "[:lower:]")
        url="https://api.github.com/repos/bazelbuild/bazelisk/releases/latest"
        header="Accept: application/vnd.github.v3+json"
        version=$(curl -fsSL -H "$header" "$url" | jq --raw-output ".tag_name")

        arch=$(uname -m)
        [[ "$arch" == "x86_64" ]] && arch="amd64"
        prefix="https://github.com/bazelbuild/bazelisk/releases/download"
        url="$prefix/$version/bazelisk-$os-$arch"
        curl -fsSL "$url" -o "$bin"
        chmod +x "$bin"
    }
    bin="$libexec/bazelisk"
    update
    "$bin" "$@"
}

run_flatc() {
    download() {
        tmp=$(mktemp -d)

        git clone git@github.com:google/flatbuffers.git "$tmp/flatbuffers"
        cd "$tmp/flatbuffers"
        git checkout "$(git tag | tail -n 1)"

        mkdir build
        cd build
        cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local"
        make
        cp flatc "$bin"

        rm -rf "$tmp"
    }
    bin="$libexec/flatc"
    update
    "$bin" "$@"
}

run_presto-cli() {
    download() {
        js_url="https://prestodb.io/static/js/version.js"
        version="$(curl -fsSL "$js_url" | grep "\<presto_latest_presto_version\>" | sed "s/[^']*'\([^']*\)';/\1/")"
        url="https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$version/presto-cli-$version-executable.jar"
        curl -fsSL "$url" -o "$bin"
        chmod +x "$bin"
    }
    bin="$libexec/presto-cli"
    update
    "$bin" "$@"
}

run_protoc() {
    download() {
        url="https://api.github.com/repos/protocolbuffers/protobuf/releases/latest"
        header="Accept: application/vnd.github.v3+json"
        version=$(curl -fsSL -H "$header" "$url" | jq --raw-output ".tag_name" | sed 's/^v//g')

        os=$(uname -s | tr "[:upper:]" "[:lower:]")
        arch=$(uname -m)
        if [[ "$os" == "darwin" ]]; then
            os="osx"
            [[ "$arch" == "arm64" ]] && arch="aarch_64"
        fi

        prefix="https://github.com/protocolbuffers/protobuf/releases/download"
        zip="protoc-$version-$os-$arch.zip"
        url="$prefix/v$version/$zip"

        tmp=$(mktemp -d)
        zip="$tmp/$zip"
        curl -fsSL "$url" -o "$zip"
        dir="$libexec/protoc"
        rm -rf "$dir"
        unzip "$zip" -d "$dir"
        rm -rf "$tmp"
        touch "$bin"
    }
    bin="$libexec/protoc/bin/protoc"
    update
    "$bin" "$@"
}

run_trino-cli() {
    download() {
        url=$(links "https://trino.io/download.html" | grep "trino-cli-[0-9]\+-executable.jar")
        curl -fsSL "$url" -o "$bin"
        chmod +x "$bin"
    }
    bin="$libexec/trino-cli"
    update
    "$bin" "$@"
}

bin="$(basename "$0")"

case "$bin" in
    b2) brew_pkg=b2-tools;;
    bazel) brew_pkg=bazelisk;;
    flatc) brew_pkg=flatbuffers;;
    protoc) brew_pkg=protobuf;;
esac

if [[ -n ${brew_pkg+x} ]] && type brew &> /dev/null; then
    brew_bin="/opt/homebrew/bin/$bin"
    [[ -L "$brew_bin" ]] || brew install "$brew_pkg"
    "$brew_bin" "$@"
else
    "run_$bin" "$@"
fi
