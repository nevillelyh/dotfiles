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
        if [[ "$i" == "$needle" ]]; then
            echo 0
            return
        fi
    done
    echo 1
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
    _bs_test_stdout "0" bs_array_contains "foo" "foo" "bar" "baz"
    _bs_test_stdout "1" bs_array_contains "foo" "bar" "baz"
    _bs_test_stdout "[]" bs_array_to_string
    _bs_test_stdout "[foo, bar, baz]" bs_array_to_string "foo" "bar" "baz"
}

############################################################
# Execution
############################################################

bs_df() {
    local path=$1
    shift
    curl -fsSL "https://raw.githubusercontent.com/nevillelyh/dotfiles/master/.dotfiles/$path" | bash -s -- "$@"
}

bs_fatal() {
    bs_error "$@"
    exit 1
}

bs_sed_i() {
    case "$BS_UNAME_S" in
        Darwin) sed -i '' "$@" ;;
        Linux) sed -i "$@" ;;
    esac
}

_bs_test_exec() {
    bs_df files/install.sh sublime
}

############################################################
# Tests
############################################################

_bs_test_stdout() {
    local expected="$1"
    shift
    local actual
    actual="$("$@")"
    if [[ "$expected" == "$actual" ]]; then
        bs_success "[PASS] $*"
    else
        bs_error "[FAIL] $*"
        echo "Test failure, expected: $expected, actual: $actual"
    fi
}

_bs_test() {
    _bs_test_ansi
    _bs_test_array
    _bs_test_exec
}
