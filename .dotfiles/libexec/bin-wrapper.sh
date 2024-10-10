#!/bin/bash

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL bit.ly/bs-dot-sh)"
fi

cache="$HOME/.dotfiles/libexec/cache"
sfpath="$HOME/.local/share/zsh/site-functions"
os=$(echo "$BS_UNAME_S" | tr "[:upper:]" "[:lower:]")
arch="$BS_UNAME_M"

brew_run() {
    [[ "$os" != darwin ]] && return 0
    local brew_pkg="$1"
    local brew_bin="/opt/homebrew/bin/$2"
    shift 2
    [[ -L "$brew_bin" ]] || brew install "$brew_pkg"
    "$brew_bin" "$@"
    exit 0
}

not_supported() {
    if [[ "$os" == "$1" ]] && [[ "$arch" == "$2" ]]; then
        echo "Not supported on $os-$arch"
        exit 1
    fi
}

update() {
    local ttl
    (( ttl = 7 * 24 * 60 * 60 ))
    local cache_ttl=${CACHE_TTL:-$ttl}

    if [[ ! -x "$exec" ]] || [[ "${REINSTALL:-0}" -eq 1 ]] ; then
        local latest
        latest=$(get_latest)
        ! [[ -t 1 ]] || bs_info "Installing $bin $latest"
        download "$latest"
    elif [[ $(bs_file_age "$exec") -ge $cache_ttl ]]; then
        local current
        local latest
        current=$(get_current)
        latest=$(get_latest)
        if [[ "$current" != "$latest" ]]; then
            ! [[ -t 1 ]] || bs_info "Upgrading $bin from $current to $latest"
            download "$latest"
        else
            ! [[ -t 1 ]] || bs_info "Up-to-date $bin: $current"
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
    [[ -d "$sfpath" ]] || mkdir -p "$sfpath"
    "$cmd" "$@" > "$sfpath/_$(basename "$cmd")"
}

run_b2() {
    brew_run b2-tools b2 "$@"
    not_supported linux aarch64

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
    exec "$exec" "$@"
}

run_bat() {
    brew_run bat bat "$@"

    get_latest() {
        bs_gh_latest sharkdp/bat
    }

    get_current() {
        "$exec" --version | sed 's/^bat \([^ ]\+\) \+(.\+)$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/sharkdp/bat/releases/download"
        local build="bat-v$version-$arch-unknown-$os-gnu"
        local tarball="$build.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz --strip-components=1 \
            "$build/bat" "$build/autocomplete/bat.zsh"
        [[ -d "$sfpath" ]] || mkdir -p "$sfpath"
        mv "$cache/autocomplete/bat.zsh" "$sfpath/_bat"
        rmdir "$cache/autocomplete"
        touch "$exec"
    }

    exec="$cache/bat"
    update
    exec "$exec" "$@"
}

run_bazel() {
    brew_run bazelisk bazel "$@"

    get_latest() {
        bs_gh_latest bazelbuild/bazelisk
    }

    get_current() {
        "$exec" version 2> /dev/null | grep '^Bazelisk version:' | sed 's/^Bazelisk version: v\(.\+\)$/\1/'
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
    exec "$exec" "$@"
}

run_bw() {
    get_latest() {
        local path="repos/bitwarden/clients/releases"
        bs_gh "$path" | jq --raw-output '.[].tag_name' | grep '^cli-v' | sed 's/^cli-v\(.*\)$/\1/' | bs_head1
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
    exec "$exec" "$@"
}

run_cfssl() {
    brew_run cfssl cfssl "$@"

    get_latest() {
        bs_gh_latest cloudflare/cfssl
    }

    get_current() {
        "$exec" version | grep '^Version:' | sed 's/^Version: \(.\+\)$/\1/'
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
    exec "$exec" "$@"
}

run_cfssljson() {
    brew_run cfssl cfssljson "$@"

    get_latest() {
        bs_gh_latest cloudflare/cfssl
    }

    get_current() {
        "$exec" --version | grep '^Version:' | sed 's/^Version: \(.\+\)$/\1/'
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
    exec "$exec" "$@"
}

run_cockroach() {
    brew_run cockroachdb/tap/cockroach cockroach "$@"

    get_latest() {
        bs_urls "https://www.cockroachlabs.com/docs/releases" | \
            grep -o '\<cockroach-v[0-9]\+\.[0-9]\+\.[0-9]\+\.linux-amd64.tgz$' | \
            sed 's/^cockroach-v\(.\+\)\.linux-amd64.tgz$/\1/' | \
            bs_head1
    }

    get_current() {
        "$exec" version | grep '^Build Tag:' | sed 's/^Build Tag: *\v(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        local prefix="https://binaries.cockroachdb.com"
        local build="cockroach-v$version.$os-$arch"
        local tarball="$build.tgz"
        local url="$prefix/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz
        rm -rf "$cache/cockroach"
        mv "$cache/$build" "$cache/cockroach"
        touch "$exec"
    }

    exec="$cache/cockroach/cockroach"
    update
    exec "$exec" "$@"
}

run_cog() {
    brew_run cog cog "$@"

    # `replicate` forbids access via a personal access token (classic).
    unset DOTFILES_GITHUB_API_TOKEN

    get_latest() {
        bs_gh_latest replicate/cog
    }

    get_current() {
        "$exec" --version | sed 's/^cog version \([^ ]\+\).*$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) ;;
            aarch64) arch=arm64 ;;
        esac
        download_gh_bin replicate/cog "$version" "cog_${BS_UNAME_S}_${arch}"
    }

    exec="$cache/cog"
    update
    exec "$exec" "$@"
}

run_delta() {
    brew_run git-delta delta "$@"

    get_latest() {
        bs_gh_latest dandavison/delta
    }

    get_current() {
        "$exec" --version | sed 's/^delta \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/dandavison/delta/releases/download"
        local build="delta-$version-$arch-unknown-$os-gnu"
        local tarball="$build.tar.gz"
        local url="$prefix/$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz --strip-components=1 "$build/delta"
        [[ -d "$sfpath" ]] || mkdir -p "$sfpath"
        curl -fsSL "https://raw.githubusercontent.com/dandavison/delta/$version/etc/completion/completion.zsh" -o "$sfpath/_delta"
        touch "$exec"
    }

    exec="$cache/delta"
    update
    exec "$exec" "$@"
}

run_dust() {
    brew_run dust dust "$@"

    get_latest() {
        bs_gh_latest bootandy/dust
    }

    get_current() {
        "$exec" --version | sed 's/^Dust \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/bootandy/dust/releases/download"
        local build="dust-v$version-$arch-unknown-$os-gnu"
        local tarball="$build.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz --strip-components=1 "$build/dust"
        [[ -d "$sfpath" ]] || mkdir -p "$sfpath"
        curl -fsSL "https://raw.githubusercontent.com/bootandy/dust/v$version/completions/_dust" -o "$sfpath/_dust"
        touch "$exec"
    }

    exec="$cache/dust"
    update
    exec "$exec" "$@"
}

run_eza() {
    brew_run eza eza "$@"

    get_latest() {
        bs_gh_latest eza-community/eza
    }

    get_current() {
        "$exec" --version | grep '^v' | sed 's/^v\(.\+\) \[.*\]$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/eza-community/eza/releases/download"
        local tarball="eza_$arch-unknown-$os-gnu.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz ./eza
        [[ -d "$sfpath" ]] || mkdir -p "$sfpath/"
        curl -fsSL "https://raw.githubusercontent.com/eza-community/eza/v$version/completions/zsh/_eza" -o "$sfpath/_eza"
        touch "$exec"
    }

    exec="$cache/eza"
    update
    exec "$exec" "$@"
}

run_fd() {
    brew_run fd fd "$@"

    get_latest() {
        bs_gh_latest sharkdp/fd
    }

    get_current() {
        "$exec" --version | sed 's/^fd \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/sharkdp/fd/releases/download"
        local build="fd-v$version-$arch-unknown-$os-gnu"
        local tarball="$build.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz --strip-components=1 \
            "$build/fd" "$build/autocomplete/_fd"
        [[ -d "$sfpath" ]] || mkdir -p "$sfpath"
        mv "$cache/autocomplete/_fd" "$sfpath"
        rmdir "$cache/autocomplete"
        touch "$exec"
    }

    exec="$cache/fd"
    update
    exec "$exec" "$@"
}

run_flatc() {
    brew_run flatbuffers flatc "$@"
    not_supported linux aarch64

    get_latest() {
        bs_gh_latest google/flatbuffers
    }

    get_current() {
        "$exec" --version | sed 's/^flatc version \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local zip="Linux.flatc.binary.g++-13.zip"
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
    exec "$exec" "$@"
}

run_fzf() {
    brew_run fzf fzf "$@"

    get_latest() {
        bs_gh_latest junegunn/fzf
    }

    get_current() {
        "$exec" --version | sed 's/^\([^ ]\+\) \+(.\+)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://github.com/junegunn/fzf/releases/download/v$version/fzf-$version-${os}_$arch.tar.gz" | tar -C "$cache" -xz fzf

        mk_comp "$exec" --zsh
    }

    exec="$cache/fzf"
    update
    exec "$exec" "$@"
}

run_gh() {
    brew_run gh gh "$@"

    get_latest() {
        bs_gh_latest cli/cli
    }

    get_current() {
        "$exec" version 2> /dev/null | grep '^gh version\>' | sed 's/^gh version \([^ ]\+\) (.\+)$/\1/'
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
    exec "$exec" "$@"
}

run_gitui() {
    brew_run gitui gitui "$@"

    get_latest() {
        bs_gh_latest extrawurst/gitui
    }

    get_current() {
        "$exec" --version | sed 's/^gitui \([^ ]\+\) .*$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/extrawurst/gitui/releases/download"
        local tarball="gitui-$os-$arch.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz ./gitui
        touch "$exec"
    }

    exec="$cache/gitui"
    update
    exec "$exec" "$@"
}

run_jq() {
    brew_run jq jq "$@"

    get_latest() {
        bs_gh "repos/jqlang/jq/releases/latest" | grep '"tag_name":' | sed 's/.*"tag_name": "\(.\+\)",.*$/\1/'
    }

    get_current() {
        "$exec" --version
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        url="https://github.com/jqlang/jq/releases/download/$version/jq-$os-$arch"
        curl -fsSL "$url" -o "$exec"
        chmod +x "$exec"
    }

    exec="$cache/jq"
    update
    exec "$exec" "$@"
}

run_k3d() {
    brew_run k3d k3d "$@"

    get_latest() {
        bs_gh_latest k3d-io/k3d
    }

    get_current() {
        "$exec" version | grep '^k3d version\>' | sed 's/^k3d version v\(.\+\)$/\1/'
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
    exec "$exec" "$@"
}

run_k9s() {
    brew_run k9s k9s "$@"

    get_latest() {
        bs_gh_latest derailed/k9s
    }

    get_current() {
        "$exec" version --short | grep '^Version\>' | sed 's/^Version \+v\?\(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://github.com/derailed/k9s/releases/download/v$version/k9s_${os}_$arch.tar.gz" | tar -C "$cache" -xz k9s

        mk_comp "$exec" completion zsh
    }

    exec="$cache/k9s"
    update
    exec "$exec" "$@"
}

run_kconf() {
    brew_run kconf kconf "$@"

    get_latest() {
        bs_gh_latest particledecay/kconf
    }

    get_current() {
        "$exec" version | sed 's/^v\+\(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://github.com/particledecay/kconf/releases/download/v$version/kconf-$os-$arch-$version.tar.gz" | tar -C "$cache" -xz kconf

        mk_comp "$exec" completion zsh
    }

    exec="$cache/kconf"
    update
    exec "$exec" "$@"
}

run_kind() {
    brew_run kind kind "$@"

    get_latest() {
        local path="repos/kubernetes-sigs/kind/releases"
        bs_gh "$path" | jq --raw-output '.[].tag_name' | bs_head1 | sed 's/^v//'
    }

    get_current() {
        "$exec" version | sed 's/^kind v\([^ ]\+\) .*$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://github.com/kubernetes-sigs/kind/releases/download/v$version/kind-$os-$arch" -o "$exec"
        chmod +x "$exec"

        mk_comp "$exec" completion zsh
    }

    exec="$cache/kind"
    update
    exec "$exec" "$@"
}

run_kubectl() {
    brew_run kubernetes-cli kubectl "$@"

    get_latest() {
        curl -L -s https://dl.k8s.io/release/stable.txt | sed 's/^v//'
    }

    get_current() {
        "$exec" version --client=true --output=json | jq --raw-output '.clientVersion.gitVersion' | sed 's/^v//'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://dl.k8s.io/release/v$version/bin/$os/$arch/kubectl" -o "$exec"
        chmod +x "$exec"

        mk_comp "$exec" completion zsh
    }

    exec="$cache/kubectl"
    update
    exec "$exec" "$@"
}

run_kubectx() {
    brew_run kubectx kubectx "$@"

    get_latest() {
        bs_gh_latest ahmetb/kubectx
    }

    get_current() {
        "$exec" --version
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/v$version/kubectx_v${version}_${os}_$arch.tar.gz" | tar -C "$cache" -xz kubectx
    }

    exec="$cache/kubectx"
    update
    exec "$exec" "$@"
}

run_kustomize() {
    brew_run kustomize kustomize "$@"

    get_latest() {
        local path="repos/kubernetes-sigs/kustomize/releases"
        bs_gh "$path" | jq --raw-output '.[].tag_name' | grep '^kustomize/v' | sed 's/^kustomize\/v\(.\+\)$/\1/' | bs_head1
    }

    get_current() {
        "$exec" version | sed 's/v\([^+]\+\).*$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv$version/kustomize_v${version}_${os}_$arch.tar.gz" | tar -C "$cache" -xz kustomize

        mk_comp "$exec" completion zsh
    }

    exec="$cache/kustomize"
    update
    exec "$exec" "$@"
}

run_lazydocker() {
    brew_run lazydocker lazydocker "$@"

    get_latest() {
        bs_gh_latest jesseduffield/lazydocker
    }

    get_current() {
        "$exec" version | grep '^Version:' | sed 's/^Version: \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) ;;
            aarch64) arch=arm64 ;;
        esac
        local prefix="https://github.com/jesseduffield/lazydocker/releases/download"
        local tarball="lazydocker_${version}_${BS_UNAME_S}_$arch.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz lazydocker
        touch "$exec"
    }

    exec="$cache/lazydocker"
    update
    exec "$exec" "$@"
}

run_minikube() {
    brew_run minikube minikube "$@"

    get_latest() {
        bs_gh_latest kubernetes/minikube
    }

    get_current() {
        "$exec" version | grep '^minikube version:' | sed 's/^minikube version: v\(.\+\)$/\1/'
    }

    download() {
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://storage.googleapis.com/minikube/releases/latest/minikube-$os-$arch" -o "$exec"
        chmod +x "$exec"

        mk_comp "$exec" completion zsh
    }

    exec="$cache/minikube"
    update
    exec "$exec" "$@"
}

run_nerdctl() {
    [[ "$os" == darwin ]] && bs_fatal "OS not supported"

    get_latest() {
        bs_gh_latest containerd/nerdctl
    }

    get_current() {
        "$exec" --version | sed 's/^nerdctl version \(.\+\)/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://github.com/containerd/nerdctl/releases/download/v$version/nerdctl-$version-$os-$arch.tar.gz" | tar -C "$cache" -xz nerdctl
        touch "$exec"
    }

    exec="$cache/nerdctl"
    update
    exec sudo "$exec" "$@"
}

run_nvim() {
    brew_run neovim nvim "$@"

    get_latest() {
        bs_gh_tags neovim/neovim | sort --version-sort | tail -n 1
    }

    get_current() {
        "$exec" --version 2> /dev/null | grep '^NVIM\>' | sed 's/^NVIM v\(.\+\)$/\1/'
    }

    download() {
        local version=$1
        download_gh_bin neovim/neovim "$version" nvim.appimage
    }

    exec="$cache/nvim"
    # Workaround for Linux arm64
    # https://github.com/matsuu/neovim-aarch64-appimage
    [[ "$os-$arch" != linux-aarch64 ]] && update
    exec "$exec" "$@"
}

run_protoc() {
    brew_run protobuf protoc "$@"

    get_latest() {
        bs_gh_latest protocolbuffers/protobuf
    }

    get_current() {
        "$exec" --version | sed 's/^libprotoc \(.\+\)$/\1/'
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
    exec "$exec" "$@"
}

run_protoc-gen-go() {
    bin=protoc-gen-go
    case "$os" in
        darwin)
            exec="/opt/homebrew/bin/$bin"
            [[ -f "$exec" ]] || brew install "$bin" &> /dev/null
            ;;
        linux)
            exec="$HOME/.go/bin/$bin"
            [[ -f "$exec" ]] || go install "google.golang.org/protobuf/cmd/$bin@latest"
            ;;
    esac
    exec "$exec" "$@"
}

run_protoc-gen-go-grpc() {
    bin=protoc-gen-go-grpc
    case "$os" in
        darwin)
            exec="/opt/homebrew/bin/$bin"
            [[ -f "$exec" ]] || brew install "$bin" &> /dev/null
            ;;
        linux)
            exec="$HOME/.go/bin/$bin"
            [[ -f "$exec" ]] || go install "google.golang.org/grpc/cmd/$bin@latest"
            ;;
    esac
    exec "$exec" "$@"
}

run_rg() {
    brew_run ripgrep rg "$@"

    get_latest() {
        bs_gh_latest BurntSushi/ripgrep
    }

    get_current() {
        "$exec" --version | grep '^ripgrep ' | sed 's/^ripgrep \([^ ]\+\).*$/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) libc=musl ;;
            aarch64) libc=gnu ;;
        esac
        local prefix="https://github.com/BurntSushi/ripgrep/releases/download"
        local build="ripgrep-$version-$arch-unknown-$os-$libc"
        local tarball="$build.tar.gz"
        local url="$prefix/$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz --strip-components=1 \
            "$build/rg" "$build/complete/_rg"
        [[ -d "$sfpath" ]] || mkdir -p "$sfpath"
        mv "$cache/complete/_rg" "$sfpath"
        rmdir "$cache/complete"
        touch "$exec"

    }

    exec="$cache/rg"
    update
    exec "$exec" "$@"
}

run_sops() {
    brew_run sops sops "$@"

    get_latest() {
        bs_gh_latest getsops/sops
    }

    get_current() {
        "$exec" --version | grep '^sops\>' | sed 's/^sops \([^ ]\+\).*$/\1/g'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64) arch=arm64 ;;
        esac
        download_gh_bin getsops/sops "$version" "sops-v$version.$os.$arch"
    }

    exec="$cache/sops"
    update
    exec "$exec" "$@"
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
    exec "$exec" "$@"
}

run_uv() {
    brew_run uv uv "$@"

    get_latest() {
        bs_gh_latest astral-sh/uv
    }

    get_current() {
        "$exec" --version | sed 's/^uv \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/astral-sh/uv/releases/download"
        local build="uv-$arch-unknown-$os-gnu"
        local tarball="$build.tar.gz"
        local url="$prefix/$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz --strip-components=1 "$build/uv" "$build/uvx"
        touch "$exec"

        mk_comp "$cache/uv" generate-shell-completion zsh
    }

    exec="$cache/uv"
    update
    exec "$exec" "$@"
}

run_uvx() {
    brew_run uv uvx "$@"

    get_latest() {
        bs_gh_latest astral-sh/uv
    }

    get_current() {
        "$exec" --version | sed 's/^uv \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/astral-sh/uv/releases/download"
        local build="uv-$arch-unknown-$os-gnu"
        local tarball="$build.tar.gz"
        local url="$prefix/$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz --strip-components=1 "$build/uv" "$build/uvx"
        touch "$exec"

        mk_comp "$cache/uv" generate-shell-completion zsh
    }

    exec="$cache/uvx"
    update
    exec "$exec" "$@"
}

run_yamlfmt() {
    brew_run yamlfmt yamlfmt "$@"

    get_latest() {
        bs_gh_latest google/yamlfmt
    }

    get_current() {
        "$exec" --version | grep '^yamlfmt\>' | sed 's/^yamlfmt \+\([^ ]\+\).*/\1/'
    }

    download() {
        local version=$1
        case "$arch" in
            x86_64) ;;
            aarch64) arch=arm64 ;;
        esac
        curl -fsSL "https://github.com/google/yamlfmt/releases/download/v$version/yamlfmt_${version}_${BS_UNAME_S}_$arch.tar.gz" | tar -C "$cache" -xz yamlfmt
    }

    exec="$cache/yamlfmt"
    update
    exec "$exec" "$@"
}

run_zoxide() {
    brew_run zoxide zoxide "$@"

    get_latest() {
        bs_gh_latest ajeetdsouza/zoxide
    }

    get_current() {
        "$exec" --version | sed 's/^zoxide \(.\+\)$/\1/'
    }

    download() {
        local version=$1
        local prefix="https://github.com/ajeetdsouza/zoxide/releases/download"
        local tarball="zoxide-$version-$arch-unknown-$os-musl.tar.gz"
        local url="$prefix/v$version/$tarball"
        curl -fsSL "$url" | tar -C "$cache" -xz \
            zoxide completions/_zoxide
        [[ -d "$sfpath" ]] || mkdir -p "$sfpath"
        mv "$cache/completions/_zoxide" "$sfpath/_zoxide"
        rmdir "$cache/completions"
        touch "$exec"
    }

    exec="$cache/zoxide"
    update
    exec "$exec" "$@"
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
