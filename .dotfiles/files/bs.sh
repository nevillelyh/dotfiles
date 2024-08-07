#!/bin/bash

# Shared library for BASH scripts

set -euo pipefail

############################################################
# Enviroment
############################################################

BS_UNAME_S=$(uname -s)
BS_UNAME_M=$(uname -m)
export BS_UNAME_S
export BS_UNAME_M

############################################################
# ANSI Escape Code
############################################################

# https://en.wikipedia.org/wiki/ANSI_escape_code

bs_info() {
    # bold, magenta
    echo -e "\033[1;35m$*\033[0m"
}

bs_warn() {
    # bold, yellow
    echo -e "\033[1;33m$*\033[0m"
}

bs_error() {
    # bold, red
    echo -e "\033[1;31m$*\033[0m"
}

bs_success() {
    # bold, green
    echo -e "\033[1;32m$*\033[0m"
}

bs_info_box() {
    _bs_msg_box bs_info "$@"
}

bs_warn_box() {
    _bs_msg_box bs_warn "$@"
}

bs_error_box() {
    _bs_msg_box bs_error "$@"
}

bs_success_box() {
    _bs_msg_box bs_success "$@"
}

_bs_msg_box() {
    local fn="$1"
    shift
    local msg="$*"
    "$fn" "╔═${msg//[[:ascii:]]/═}═╗"
    "$fn" "║ $msg ║"
    "$fn" "╚═${msg//[[:ascii:]]/═}═╝"
}

_bs_test_ansi() {
    bs_info "INFO" "foo" "bar"
    bs_warn "WARN" "foo" "bar"
    bs_error "ERROR" "foo" "bar"
    bs_success "SUCCESS" "foo" "bar"
    bs_info_box "INFO" "foo" "bar"
    bs_warn_box "WARN" "foo" "bar"
    bs_error_box "ERROR" "foo" "bar"
    bs_success_box "SUCCESS" "foo" "bar"
}

############################################################
# Array
############################################################

bs_array_contains() {
    local needle="$1"
    shift
    for i in "$@"; do
        [[ "$i" == "$needle" ]] && return 0
    done
    return 1
}

bs_array_to_string() {
    if [[ $# -eq 0 ]]; then
        echo "[]"
        return
    fi
    local res=""
    for s in "$@"; do
        if [[ -z "$res" ]]; then
            res="[$s"
        else
            res="$res, $s"
        fi
    done
    res="$res]"
    echo "$res"
}

_bs_test_array() {
    _bs_test_true bs_array_contains "foo" "foo" "bar" "baz"
    _bs_test_false bs_array_contains "foo" "bar" "baz"
    _bs_test_stdout "[]" bs_array_to_string
    _bs_test_stdout "[foo, bar, baz]" bs_array_to_string "foo" "bar" "baz"
}

############################################################
# Execution
############################################################

_bs_cmds() {
    # curl URL | bash
    [[ "$0" == bash ]] && return

    # Bash 3 on Mac missing readarray
    # shellcheck disable=SC2207
    cmds=($(grep -o '^cmd_\(\w\|[_-]\)\+()' "$(readlink -f "$0")" | sed 's/^cmd_\(.*\)()$/\1/'))
}

bs_cmd_args() {
    local name=$0
    _bs_cmds
    if [[ $# -eq 0 ]] || { [[ $# -eq 1 ]] && [[ "$1" == help ]]; } then
        echo "Usage: $(basename "$name") <COMMAND> [ARG]..."
        if [[ -n "${cmds[*]}" ]]; then
            echo "    Commands:"
            echo "        help"
            for cmd in "${cmds[@]}"; do
                local h="cmd_${cmd}_help"
                if [[ -z "${!h:-}" ]]; then
                    echo "        $cmd"
                else
                    echo "        $cmd ${!h}"
                fi
            done
        fi
        exit 1
    fi

    cmd=$1
    shift
    if bs_array_contains "$cmd" "${cmds[@]}"; then
        "cmd_$cmd" "$@"
    else
        bs_fatal "Command not found: $cmd"
    fi
}

bs_cmd_optional() {
    local name=$0
    local default=$1
    _bs_cmds
    if [[ $# -eq 1 ]]; then
        "$default"
    elif [[ $# -eq 2 ]] && [[ "$2" == help ]]; then
        echo "Usage: $(basename "$name") <COMMAND>..."
        echo "    Commands:"
        echo "        help"
        for cmd in "${cmds[@]}"; do
            echo "        $cmd"
        done
        exit 1
    fi

    shift
    for cmd in "$@"; do
        if bs_array_contains "$cmd" "${cmds[@]}"; then
            "cmd_$cmd"
        else
            bs_fatal "Command not found: $cmd"
        fi
    done
}

bs_cmd_required() {
    local name=$0
    _bs_cmds
    if [[ $# -eq 0 ]]; then
        echo "Usage: $(basename "$name") <COMMAND>..."
        if [[ -n "${cmds[*]}" ]]; then
            echo "    Commands:"
            for cmd in "${cmds[@]}"; do
                echo "        $cmd"
            done
        fi
        exit 1
    fi

    for cmd in "$@"; do
        if bs_array_contains "$cmd" "${cmds[@]}"; then
            "cmd_$cmd"
        else
            bs_fatal "Command not found: $cmd"
        fi
    done
}

bs_df() {
    local path=$1
    shift
    if [[ -f "$HOME/.dotfiles/$path" ]]; then
        bash "$HOME/.dotfiles/$path" "$@"
    else
        file=$(bs_temp_file bs-df)
        curl -fsSL "https://raw.githubusercontent.com/nevillelyh/dotfiles/master/.dotfiles/$path" -o "$file"
        bash "$file" "$@"
        rm "$file"
    fi
}

bs_fatal() {
    bs_error "$@"
    exit 1
}

bs_head1() {
    case "$BS_UNAME_S" in
        Darwin) tail -r | tail -n 1 ;;
        Linux) tac | tail -n 1 ;;
    esac
}

bs_headn() {
    case "$BS_UNAME_S" in
        Darwin) tail -r | tail -n "$1" | tail -r ;;
        Linux) tac | tail -n "$1" | tac ;;
    esac
}

bs_sed_i() {
    case "$BS_UNAME_S" in
        Darwin) sed -i '' "$@" ;;
        Linux) sed -i "$@" ;;
    esac
}

bs_timestamp() {
    date "$@" "+%Y%m%d%H%M%S"
}

_bs_test_exec() {
    _bs_test_stdout "pong" bs_df files/bs-test.sh ping

    local file
    file=$(bs_temp_file bs-test)
    { echo "foo" ; echo "bar" ; echo "baz" ; } > "$file"
    bs_head1 < "$file" > "$file.head"
    _bs_test_stdout "foo" cat "$file.head"
    bs_headn 2 < "$file" | tr '\n' ':' > "$file.head"
    _bs_test_stdout "foo:bar:" cat "$file.head"
    rm "$file" "$file.head"

    local file
    file=$(bs_temp_file bs-test)
    echo "foobar" > "$file"
    bs_sed_i 's/bar/baz/g' "$file"
    _bs_test_stdout "foobaz" cat "$file"
    rm "$file"

    local args
    case "$BS_UNAME_S" in
        Darwin) args=(-r 1672531200 -u) ;;
        Linux)  args=(-d "2023-01-01 00:00:00" -u) ;;
    esac
    _bs_test_stdout "20230101000000" bs_timestamp "${args[@]}"
}

############################################################
# Resources
############################################################

bs_file_age() {
    local file=$1
    echo "$(date "+%s")" - "$(date -r "$file" "+%s")" | bc -l
}

bs_urls() {
    local url=$1
    curl -fsSL "$url" | grep -o 'href="[^"]\+"' | sed 's/href="\([^"]*\)"/\1/'
}

bs_gh() {
    local path=$1
    local url="https://api.github.com/$path"
    local headers=(-H "Accept: application/vnd.github.v3+json")
    if [[ -n "${DOTFILES_GITHUB_API_TOKEN:-}" ]]; then
        headers+=(-H "Authorization: Bearer $DOTFILES_GITHUB_API_TOKEN")
    fi
    curl -fsSL "${headers[@]}" "$url"
}

bs_gh_latest() {
    local repo=$1
    bs_gh "repos/$repo/releases/latest" | jq --raw-output '.tag_name' | sed 's/^v//g'
}

bs_gh_releases() {
    local repo=$1
    bs_gh "repos/$repo/releases" | jq --raw-output '.[].tag_name' | sed 's/^v//g'
}

bs_gh_tags() {
    local repo=$1
    bs_gh "repos/$repo/tags" | jq --raw-output '.[].name' | sed 's/^v//g'
}

bs_temp_file() {
    local prefix=$1
    local path
    case "$BS_UNAME_S" in
        Darwin) path=$(mktemp -t "$prefix") ;;
        Linux)  path=$(mktemp -t "$prefix.XXXXXXXX") ;;
    esac
    echo "$path"
}

bs_temp_dir() {
    local prefix=$1
    local path
    case "$BS_UNAME_S" in
        Darwin) path=$(mktemp -d -t "$prefix") ;;
        Linux)  path=$(mktemp -d -t "$prefix.XXXXXXXX") ;;
    esac
    echo "$path"
}

_bs_test_resources() {
    local path
    local base

    path="$(bs_temp_file bs-test)"
    sleep 1
    _bs_test_stdout "1" bs_file_age "$path"
    rm "$path"

    local url
    url=$(bs_urls https://github.com/nevillelyh | grep -c '^https://github.com$' || true)
    if [[ $url -eq 0 ]]; then
        _bs_test_fail "bs_urls https://github.com/nevillelyh"
    else
        _bs_test_pass "bs_urls https://github.com/nevillelyh"
    fi

    local tags
    tags="$(echo -e "0.2.0\n0.1.10\n0.1.9\n0.1.8\n0.1.7\n0.1.6\n0.1.5\n0.1.4\n0.1.3\n0.1.2\n0.1.1\n0.1.0")"
    _bs_test_stdout "0.2.0" bs_gh_latest nevillelyh/shapeless-datatype
    _bs_test_stdout "$tags" bs_gh_releases nevillelyh/shapeless-datatype
    _bs_test_stdout "$tags" bs_gh_tags nevillelyh/shapeless-datatype

    path="$(bs_temp_file bs-test)"
    base="$(basename "$path")"

    if [[ -f "$path" ]] && [[ "$path" = /* ]] && [[ "$base" = bs-test.* ]]; then
        _bs_test_pass "bs_temp_file $path"
    else
        _bs_test_fail "bs_temp_file $path"
    fi
    rm "$path"

    path="$(bs_temp_dir bs-test)"
    base="$(basename "$path")"
    if [[ -d "$path" ]] && [[ "$path" = /* ]] && [[ "$base" = bs-test.* ]]; then
        _bs_test_pass "bs_temp_dir $path"
    else
        _bs_test_fail "bs_temp_dir $path"
    fi
    rm -rf "$path"

}

############################################################
# Tests
############################################################

_bs_test_passes=0
_bs_test_failures=0

_bs_test_fail() {
    (( _bs_test_failures = _bs_test_failures + 1 ))
    bs_error "[FAIL] $*"
}

_bs_test_pass() {
    (( _bs_test_passes = _bs_test_passes + 1 ))
    bs_success "[PASS] $*"
}

_bs_test_stdout() {
    local expected="$1"
    shift
    local actual
    actual="$("$@")"
    if [[ "$expected" == "$actual" ]]; then
        _bs_test_pass "$@"
    else
        _bs_test_fail "$@"
        echo "Test failure, expected: $expected, actual: $actual"
    fi
}

_bs_test_true() {
    if "$@" &> /dev/null; then
        _bs_test_pass "$@"
    else
        _bs_test_fail "$@"
        echo "Test failure, expected: true, actual: false"
    fi
}

_bs_test_false() {
    if "$@" &> /dev/null; then
        _bs_test_fail "$@"
        echo "Test failure, expected: false, actual: true"
    else
        _bs_test_pass "$@"
    fi
}

_bs_test() {
    _bs_test_ansi
    _bs_test_array
    _bs_test_exec
    _bs_test_resources
    (( _bs_test_total = _bs_test_passes + _bs_test_failures ))
    if [[ $_bs_test_failures -eq 0 ]]; then
        bs_success "All $_bs_test_total tests passed"
    else
        bs_fatal "$_bs_test_failures out of $_bs_test_total tests failed"
    fi
}
