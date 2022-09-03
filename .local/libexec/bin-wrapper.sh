#!/bin/bash

set -euo pipefail

libexec="$HOME/.local/libexec"
os=$(uname -s | tr "[:upper:]" "[:lower:]")
arch=$(uname -m)
header="Accept: application/vnd.github.v3+json"

get_links() {
    url=$1
    curl -fsSL "$url" | grep -o 'href="[^"]\+"' | sed 's/href="\([^"]*\)"/\1/'
}

github_latest() {
    repo=$1
    url="https://api.github.com/repos/$repo/releases/latest"
    curl -fsSL -H "$header" "$url" | jq --raw-output ".tag_name" | sed 's/^v//g'
}

update() {
    (( ttl = 7 * 24 * 60 * 60 ))

    if [[ ! -x "$exec" ]]; then
        latest=$(get_latest)
        echo "Installing $bin $latest"
        download "$latest"
    else
        age=$(echo "$(date "+%s")" - "$(date -r "$exec" "+%s")" | bc -l)
        if [[ $age -ge $ttl ]]; then
            current=$(get_current)
            latest=$(get_latest)
            if [[ "$current" != "$latest" ]]; then
                echo "Upgrading $bin from $current to $latest"
                download "$latest"
            else
                echo "Up-to-date $bin: $current"
            fi
        fi
    fi
}

run_b2() {
    get_latest() {
        github_latest "Backblaze/B2_Command_Line_Tool"
    }

    get_current() {
        "$exec" version | sed 's/^b2 command line tool, version \(.\+\)$/\1/'
    }

    download() {
        version=$1
        prefix="https://github.com/Backblaze/B2_Command_Line_Tool/releases/download"
        url="$prefix/v$version/b2-$os"
        curl -fsSL "$url" -o "$exec"
        chmod +x "$exec"
    }

    exec="$libexec/b2"
    update
    "$exec" "$@"
}

run_bazel() {
    get_latest() {
        github_latest "bazelbuild/bazelisk"
    }

    get_current() {
        "$exec" version 2> /dev/null | head -n 1 | sed 's/^Bazelisk version: v\(.\+\)$/\1/'
    }

    download() {
        version=$1
        [[ "$arch" == "x86_64" ]] && arch="amd64"
        prefix="https://github.com/bazelbuild/bazelisk/releases/download"
        url="$prefix/v$version/bazelisk-$os-$arch"
        curl -fsSL "$url" -o "$exec"
        chmod +x "$exec"
    }

    exec="$libexec/bazelisk"
    update
    "$exec" "$@"
}

run_flatc() {
    get_latest() {
        github_latest "google/flatbuffers"
    }

    get_current() {
        "$exec" --version | sed 's/^flatc version \(.\+\)$/\1/'
    }

    download() {
        version=$1

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
        rm -rf "$exec"
        unzip -q "$zip" -d "$libexec"
        rm -rf "$tmp"
        touch "$exec"
    }

    exec="$libexec/flatc"
    update
    "$exec" "$@"
}

run_gh() {
    get_latest() {
        github_latest "cli/cli"
    }

    get_current() {
        "$exec" --version 2> /dev/null | head -n 1 | sed 's/gh version \(.\+\) (.\+)$/\1/'
    }

    download() {
        version=$1

        [[ "$os" == "darwin" ]] && os="macOS"
        [[ "$arch" == "x86_64" ]] && arch="amd64"

        prefix="https://github.com/cli/cli/releases/download"
        build="gh_${version}_${os}_$arch"
        tarball="$build.tar.gz"
        url="$prefix/v$version/$tarball"

        curl -fsSL "$url" | tar -C "$libexec" -xz
        rm -rf "$libexec/gh"
        mv "$libexec/$build" "$libexec/gh"
        touch "$exec"
    }

    exec="$libexec/gh/bin/gh"
    update
    "$exec" "$@"
}

run_presto-cli() {
    get_latest() {
        js_url="https://prestodb.io/static/js/version.js"
        curl -fsSL "$js_url" | grep "\<presto_latest_presto_version\>" | sed "s/[^']*'\([^']*\)';/\1/"
    }

    get_current() {
        "$exec" --version | sed 's/^Presto CLI \([^-]\+\)-.\+$/\1/'
    }

    download() {
        version=$1
        url="https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$version/presto-cli-$version-executable.jar"
        curl -fsSL "$url" -o "$exec"
        chmod +x "$exec"
    }

    exec="$libexec/presto-cli"
    update
    "$exec" "$@"
}

run_protoc() {
    get_latest() {
        github_latest "protocolbuffers/protobuf"
    }

    get_current() {
        "$exec" --version | sed 's/^libprotoc [0-9]\+\.\(.\+\)$/\1/'
    }

    download() {
        version=$1

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
        unzip -q "$zip" -d "$dir"
        rm -rf "$tmp"
        touch "$exec"
    }

    exec="$libexec/protoc/bin/protoc"
    update
    "$exec" "$@"
}

run_trino-cli() {
    prefix="https://repo1.maven.org/maven2/io/trino/trino-cli"

    get_latest() {
        get_links "$prefix" | grep -o '^[0-9]\+\/$' | sed 's/\/$//' | sort -n | tail -n 1
    }

    get_current() {
        "$exec" --version | sed 's/^Trino CLI \(.\+\)$/\1/'
    }

    download() {
        version=$1
        url="$prefix/$version/trino-cli-$version-executable.jar"
        curl -fsSL "$url" -o "$exec"
        chmod +x "$exec"
    }

    exec="$libexec/trino-cli"
    update
    "$exec" "$@"
}

get_bins() {
    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    bins=($(grep -o "^run_.\+()" "$(readlink -f "$0")" | sed "s/^run_\(.*\)()$/\1/"))
}

bin="$(basename "$0")"

case "$bin" in
    b2) brew_pkg=b2-tools;;
    bazel) brew_pkg=bazelisk;;
    flatc) brew_pkg=flatbuffers;;
    gh) brew_pkg=gh;;
    protoc) brew_pkg=protobuf;;
    bin-wrapper.sh)
        get_bins
        echo "Binary wrapper for: ${bins[*]}"
        exit 1
        ;;
esac

if [[ -n ${brew_pkg+x} ]] && type brew &> /dev/null; then
    brew_bin="/opt/homebrew/bin/$bin"
    [[ -L "$brew_bin" ]] || brew install "$brew_pkg"
    "$brew_bin" "$@"
else
    "run_$bin" "$@"
fi
