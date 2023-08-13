#!/bin/bash

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL bit.ly/bs-dot-sh)"
fi

cache="$HOME/.dotfiles/libexec/cache"
os=$(echo "$BS_UNAME_S" | tr "[:upper:]" "[:lower:]")
arch="$BS_UNAME_M"

brew_run() {
    [[ "$BS_UNAME_S" != Darwin ]] && return 0
    local brew_pkg="$1"
    local brew_bin="/opt/homebrew/bin/$2"
    shift 2
    [[ -L "$brew_bin" ]] || brew install "$brew_pkg"
    "$brew_bin" "$@"
    exit 0
}

update() {
    local ttl
    (( ttl = 7 * 24 * 60 * 60 ))

    if [[ ! -x "$exec" ]]; then
        local latest
        latest=$(get_latest)
        bs_info "Installing $bin $latest"
        download "$latest"
    elif [[ $(bs_file_age "$exec") -ge $ttl ]]; then
        local current
        local latest
        current=$(get_current)
        latest=$(get_latest)
        if [[ "$current" != "$latest" ]]; then
            bs_info "Upgrading $bin from $current to $latest"
            download "$latest"
        else
            bs_info "Up-to-date $bin: $current"
            touch "$exec"
        fi
    fi
}

download_gh_bin() {
    local repo=$1
    local version=$2
    local bin=$3
    local prefix="https://github.com/$repo/releases/download"
    local url="$prefix/v$version/$bin"
    curl -fsSL "$url" -o "$exec"
    chmod +x "$exec"
}

mk_comp() {
    local cmd=$1
    shift
    local sfpath="$HOME/.local/share/zsh/site-functions"
    [[ -d "$sfpath" ]] || mkdir -p "$sfpath"
    "$cmd" "$@" > "$sfpath/_$(basename "$cmd")"
}

run_b2() {
    brew_run b2-tools b2 "$@"

    get_latest() {
        bs_gh_latest Backblaze/B2_Command_Line_Tool
    }

    get_current() {
        "$exec" version | sed 's/^b2 command line tool, version \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        download_gh_bin Backblaze/B2_Command_Line_Tool "$version" "b2-$os"
    }

    exec="$cache/b2"
    update
    "$exec" "$@"
}

run_bazel() {
    brew_run bazelisk bazel "$@"

    get_latest() {
        bs_gh_latest bazelbuild/bazelisk
    }

    get_current() {
        "$exec" version 2> /dev/null | head -n 1 | sed 's/^Bazelisk version: v\(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        download_gh_bin bazelbuild/bazelisk "$version" "bazelisk-$os-$arch"
    }

    exec="$cache/bazelisk"
    update
    "$exec" "$@"
}

run_bw() {
    get_latest() {
        local url="https://api.github.com/repos/bitwarden/clients/releases"
        local header="Accept: application/vnd.github.v3+json"
        curl -fsSL -H "$header" "$url" | jq --raw-output '.[].tag_name' | grep "^cli-v" | sed 's/cli-v\(.\+\)$/\1/' | head -n 1
    }

    get_current() {
        "$exec" --version
    }

    download() {
        local version=$1
        [[ "$os" == darwin ]] && os=macos
        local zip="bw-$os-$version.zip"
        local url="https://github.com/bitwarden/clients/releases/download/cli-v$version/$zip"
        local tmp
        tmp=$(bs_temp_dir bin-wrapper-bw)
        zip="$tmp/$zip"
        curl -fsSL "$url" -o "$zip"
        rm -f "$exec"
        unzip -q "$zip" -d "$cache"
        rm -rf "$tmp"
        touch "$exec"

        mk_comp "$exec" completion --shell zsh
    }

    exec="$cache/bw"
    # Workaround for Linux arm64
    # $HOME/.dotfiles/builds/bitwarden/build.sh
    [[ "$os-$arch" != linux-aarch64 ]] && update
    "$exec" "$@"
}

run_cfssl() {
    brew_run cfssl cfssl "$@"

    get_latest() {
        bs_gh_latest cloudflare/cfssl
    }

    get_current() {
        "$exec" version | head -n 1 | sed 's/^Version: \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        download_gh_bin cloudflare/cfssl "$version" "cfssl_${version}_${os}_${arch}"
    }

    exec="$cache/cfssl"
    update
    "$exec" "$@"
}

run_cfssljson() {
    brew_run cfssl cfssljson "$@"

    get_latest() {
        bs_gh_latest cloudflare/cfssl
    }

    get_current() {
        "$exec" --version | head -n 1 | sed 's/^Version: \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        download_gh_bin cloudflare/cfssl "$version" "cfssljson_${version}_${os}_${arch}"
    }

    exec="$cache/cfssljson"
    update
    "$exec" "$@"
}

run_cockroach() {
    brew_run cockroachdb/tap/cockroach cockroach "$@"

    get_latest() {
        bs_urls "https://www.cockroachlabs.com/docs/releases" | \
            grep -o '\<cockroach-v[0-9]\+\.[0-9]\+\.[0-9]\+\.linux-amd64.tgz$' | \
            sed 's/^cockroach-\(.*\)\.linux-amd64.tgz$/\1/' | \
            head -n 1
    }

    get_current() {
        "$exec" version | head -n 1 | sed 's/^Build Tag: *\(v.*\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        local prefix="https://binaries.cockroachdb.com"
        local build="cockroach-$version.$os-$arch"
        local tarball="$build.tgz"
        local url="$prefix/$tarball"
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
    brew_run flatbuffers flatc "$@"

    get_latest() {
        bs_gh_latest google/flatbuffers
    }

    get_current() {
        "$exec" --version | sed 's/^flatc version \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local zip="Linux.flatc.binary.g++-10.zip"
        local prefix="https://github.com/google/flatbuffers/releases/download"
        local url="$prefix/v$version/$zip"
        local tmp
        tmp=$(bs_temp_dir bin-wrapper-flatc)
        zip="$tmp/$zip"
        curl -fsSL "$url" -o "$zip"
        rm -f "$exec"
        unzip -q "$zip" -d "$cache"
        rm -rf "$tmp"
        touch "$exec"
    }

    exec="$cache/flatc"
    update
    "$exec" "$@"
}

run_gh() {
    brew_run gh gh "$@"

    get_latest() {
        bs_gh_latest cli/cli
    }

    get_current() {
        "$exec" --version 2> /dev/null | head -n 1 | sed 's/gh version \(.\+\) (.\+)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        local prefix="https://github.com/cli/cli/releases/download"
        local build="gh_${version}_${os}_$arch"
        local tarball="$build.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz
        rm -rf "$cache/gh"
        mv "$cache/$build" "$cache/gh"
        touch "$exec"

        mk_comp "$exec" completion --shell zsh
    }

    exec="$cache/gh/bin/gh"
    update
    "$exec" "$@"
}

run_helm() {
    brew_run helm helm "$@"

    get_latest() {
        bs_gh_latest helm/helm
    }

    get_current() {
        "$exec" version --short | sed 's/v\([^+]\+\).\+/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://get.helm.sh/helm-v$version-$os-$arch.tar.gz" | tar -C "$cache" -xz --strip 1 "$os-$arch/helm"

        mk_comp "$exec" completion zsh
    }

    exec="$cache/helm"
    update
    "$exec" "$@"
}

run_k3d() {
    brew_run k3d k3d "$@"

    get_latest() {
        bs_gh_latest k3d-io/k3d
    }

    get_current() {
        "$exec" --version | head -n 1 | sed 's/^k3d version v\(.\+\)/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        download_gh_bin k3d-io/k3d "$version" "k3d-$os-$arch"

        mk_comp "$exec" completion zsh
    }

    exec="$cache/k3d"
    update
    "$exec" "$@"
}

run_lazydocker() {
    brew_run lazydocker lazydocker "$@"

    get_latest() {
        bs_gh_latest jesseduffield/lazydocker
    }

    get_current() {
        "$exec" --version | head -n 1 | sed 's/^Version: \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) ;;
            aarch64) arch=arm64 ;;
        esac
        local prefix="https://github.com/jesseduffield/lazydocker/releases/download"
        local build="lazydocker_${version}_${BS_UNAME_S}_$arch"
        local tarball="$build.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz lazydocker
        touch "$exec"
    }

    exec="$cache/lazydocker"
    update
    "$exec" "$@"
}

run_nvim() {
    brew_run neovim nvim "$@"

    get_latest() {
        bs_gh_tags neovim/neovim | sort --version-sort | tail -n 1
    }

    get_current() {
        "$exec" --version 2> /dev/null | head -n 1 | sed 's/^NVIM v\(.\+\)$/\1/'
    }

    download() {
        local version=$1
        download_gh_bin neovim/neovim "$version" nvim.appimage
    }

    exec="$cache/nvim"
    # Workaround for Linux arm64
    # https://github.com/matsuu/neovim-aarch64-appimage
    [[ "$os-$arch" != linux-aarch64 ]] && update
    update
    "$exec" "$@"
}

run_presto() {
    get_latest() {
        js_url="https://prestodb.io/static/js/version.js"
        curl -fsSL "$js_url" | grep '\<presto_latest_presto_version\>' | sed "s/[^']*'\([^']*\)';$/\1/"
    }

    get_current() {
        "$exec" --version | sed 's/^Presto CLI \([^-]\+\)-.\+$/\1/'
    }

    download() {
        local version=$1
        local url="https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$version/presto-cli-$version-executable.jar"
        curl -fsSL "$url" -o "$exec"
        chmod +x "$exec"
    }

    exec="$cache/presto"
    update
    "$exec" "$@"
}

run_protoc() {
    brew_run protobuf protoc "$@"

    get_latest() {
        bs_gh_latest protocolbuffers/protobuf
    }

    get_current() {
        "$exec" --version | sed 's/^libprotoc [0-9]\+\.\(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) ;;
            aarch64) arch=aarch_64 ;;
        esac
        local prefix="https://github.com/protocolbuffers/protobuf/releases/download"
        local zip="protoc-$version-$os-$arch.zip"
        local url="$prefix/v$version/$zip"
        local tmp
        tmp=$(bs_temp_dir bin-wrapper-protoc)
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

run_trino() {
    prefix="https://repo1.maven.org/maven2/io/trino/trino-cli"

    get_latest() {
        bs_urls "$prefix" | grep -o '^[0-9]\+\/$' | sed 's/\/$//' | sort -n | tail -n 1
    }

    get_current() {
        "$exec" --version | sed 's/^Trino CLI \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local url="$prefix/$version/trino-cli-$version-executable.jar"
        curl -fsSL "$url" -o "$exec"
        chmod +x "$exec"
    }

    exec="$cache/trino"
    update
    "$exec" "$@"
}

get_bins() {
    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    bins=($(grep -o '^run_.\+()' "$(readlink -f "$0")" | sed 's/^run_\(.*\)()$/\1/'))
}

bin="$(basename "$0")"

if [[ "$bin" == bin-wrapper.sh ]]; then
    get_bins
    echo "Binary wrapper for:"
    for bin in "${bins[@]}"; do
        echo "    $bin"
    done
    exit 1
fi

"run_$bin" "$@"
