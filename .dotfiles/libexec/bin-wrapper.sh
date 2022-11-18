#!/bin/bash

set -euo pipefail

cache="$HOME/.dotfiles/libexec/cache"
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
    curl -fsSL -H "$header" "$url" | jq --raw-output '.tag_name' | sed 's/^v//g'
}

update() {
    (( ttl = 7 * 24 * 60 * 60 ))

    color='\033[1;35m' # magenta
    reset='\033[0m' #reset
    if [[ ! -x "$exec" ]]; then
        latest=$(get_latest)
        echo -e "${color}Installing $bin $latest${reset}"
        download "$latest"
    else
        age=$(echo "$(date "+%s")" - "$(date -r "$exec" "+%s")" | bc -l)
        if [[ $age -ge $ttl ]]; then
            current=$(get_current)
            latest=$(get_latest)
            if [[ "$current" != "$latest" ]]; then
                echo -e "${color}Upgrading $bin from $current to $latest${reset}"
                download "$latest"
            else
                echo -e "${color}Up-to-date $bin: $current${reset}"
                touch "$exec"
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

    exec="$cache/b2"
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

    exec="$cache/bazelisk"
    update
    "$exec" "$@"
}

run_cockroach() {
    get_latest() {
        get_links "https://www.cockroachlabs.com/docs/releases" | \
            grep -o '\<cockroach-v[0-9]\+\.[0-9]\+\.[0-9]\+\.linux-amd64.tgz$' | \
            sed 's/^cockroach-\(.*\)\.linux-amd64.tgz$/\1/' | \
            head -n 1
    }

    get_current() {
        "$exec" version | head -n 1 | sed 's/^Build Tag: *\(v.*\)$/\1/'
    }

    download() {
        version=$1
        # shellcheck disable=SC2001
        major="$(echo "$version" | sed 's/v\([0-9]*\)\..*/\1/')"
        # shellcheck disable=SC2001
        minor="$(echo "$version" | sed 's/v[0-9]*\.\([0-9]*\)\..*/\1/')"
        [[ "$arch" == "x86_64" ]] && arch="amd64"
        if [[ "$os" == "darwin" ]]; then
            arch="10.9-amd64"
            if [[ "$arch" == "arm64" ]]; then
                if [[ "$major" -gt 22 ]] || { [[ "$major" -eq 22 ]] && [[ "$minor" -ge 2 ]]; }; then
                    arch="11.0-aarch64"
                fi
            fi
        fi
        prefix="https://binaries.cockroachdb.com"
        build="cockroach-$version.$os-$arch"
        tarball="$build.tgz"
        url="$prefix/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz
        rm -rf "$cache/cockroach"
        mv "$cache/$build" "$cache/cockroach"
        touch "$exec"
    }

    exec="$cache/cockroach/cockroach"
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
        rm "$exec"
        unzip -q "$zip" -d "$cache"
        rm -rf "$tmp"
        touch "$exec"
    }

    exec="$cache/flatc"
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

        curl -fsSL "$url" | tar -C "$cache" -xz
        rm -rf "$cache/gh"
        mv "$cache/$build" "$cache/gh"
        touch "$exec"
    }

    exec="$cache/gh/bin/gh"
    update
    "$exec" "$@"
}

run_presto-cli() {
    get_latest() {
        js_url="https://prestodb.io/static/js/version.js"
        curl -fsSL "$js_url" | grep '\<presto_latest_presto_version\>' | sed "s/[^']*'\([^']*\)';/\1/"
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

    exec="$cache/presto-cli"
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
        dir="$cache/protoc"
        rm -rf "$dir"
        unzip -q "$zip" -d "$dir"
        rm -rf "$tmp"
        touch "$exec"
    }

    exec="$cache/protoc/bin/protoc"
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

    exec="$cache/trino-cli"
    update
    "$exec" "$@"
}

get_bins() {
    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    bins=($(grep -o '^run_.\+()' "$(readlink -f "$0")" | sed 's/^run_\(.*\)()$/\1/'))
}

bin="$(basename "$0")"

case "$bin" in
    b2) brew_pkg=b2-tools;;
    bazel) brew_pkg=bazelisk;;
    cockroach) brew_pkg=cockroachdb/tap/cockroach;;
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
