#!/bin/bash

set -euo pipefail

libexec="$HOME/.local/libexec"
os=$(uname -s | tr "[:upper:]" "[:lower:]")
arch=$(uname -m)

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
        url="https://api.github.com/repos/Backblaze/B2_Command_Line_Tool/releases/latest"
        header="Accept: application/vnd.github.v3+json"
        version=$(curl -fsSL -H "$header" "$url" | jq --raw-output ".tag_name" | sed 's/^v//g')

        prefix="https://github.com/Backblaze/B2_Command_Line_Tool/releases/download"
        url="$prefix/v$version/b2-$os"
        curl -fsSL "$url" -o "$bin"
        chmod +x "$bin"
    }
    bin="$libexec/b2"
    update
    "$bin" "$@"
}

run_bazel() {
    download() {
        url="https://api.github.com/repos/bazelbuild/bazelisk/releases/latest"
        header="Accept: application/vnd.github.v3+json"
        version=$(curl -fsSL -H "$header" "$url" | jq --raw-output ".tag_name" | sed 's/^v//g')

        [[ "$arch" == "x86_64" ]] && arch="amd64"
        prefix="https://github.com/bazelbuild/bazelisk/releases/download"
        url="$prefix/v$version/bazelisk-$os-$arch"
        curl -fsSL "$url" -o "$bin"
        chmod +x "$bin"
    }
    bin="$libexec/bazelisk"
    update
    "$bin" "$@"
}

run_flatc() {
    download() {
        url="https://api.github.com/repos/google/flatbuffers/releases/latest"
        header="Accept: application/vnd.github.v3+json"
        version=$(curl -fsSL -H "$header" "$url" | jq --raw-output ".tag_name" | sed 's/^v//g')

        if [[ "$os" == "darwin" ]]; then
            zip="Mac.flatc.binary.zip"
        elif [[ "$os" == "linux" ]]; then
            zip="Linux.flatc.binary.g++-10.zip"
        fi

        prefix="https://github.com/google/flatbuffers/releases/download"
        url="$prefix/v$version/$zip"

        tmp=$(mktemp -d)
        zip="$tmp/$zip"
        curl -fsSL "$url" -o "$zip"
        rm -rf "$bin"
        unzip "$zip" -d "$libexec"
        rm -rf "$tmp"
        touch "$bin"
    }
    bin="$libexec/flatc"
    update
    "$bin" "$@"
}

run_gh() {
    download() {
        url="https://api.github.com/repos/cli/cli/releases/latest"
        header="Accept: application/vnd.github.v3+json"
        version=$(curl -fsSL -H "$header" "$url" | jq --raw-output ".tag_name" | sed 's/^v//g')

        [[ "$os" == "darwin" ]] && os="macOS"
        [[ "$arch" == "x86_64" ]] && arch="amd64"

        prefix="https://github.com/cli/cli/releases/download"
        build="gh_${version}_${os}_$arch"
        tarball="$build.tar.gz"
        url="$prefix/v$version/$tarball"

        curl -fsSL "$url" | tar -C "$libexec" -xz
        rm -rf "$libexec/gh"
        mv "$libexec/$build" "$libexec/gh"
        touch "$bin"
    }
    bin="$libexec/gh/bin/gh"
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
        prefix="https://repo1.maven.org/maven2/io/trino/trino-cli"
        version=$(links "$prefix" | grep -oP '^[0-9]+(?=/$)' | sort -n | tail -n 1)
        url="$prefix/$version/trino-cli-$version-executable.jar"
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
    gh) brew_pkg=gh;;
    protoc) brew_pkg=protobuf;;
esac

if [[ -n ${brew_pkg+x} ]] && type brew &> /dev/null; then
    brew_bin="/opt/homebrew/bin/$bin"
    [[ -L "$brew_bin" ]] || brew install "$brew_pkg"
    "$brew_bin" "$@"
else
    "run_$bin" "$@"
fi
