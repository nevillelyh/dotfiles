#!/bin/bash

# Manage SDKMAN packages

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL bit.ly/bs-dot-sh)"
fi

java_versions=(8 11 17 20)
java_default=17
java_dist="amzn"
scala_versions=(2.13 3)
scala_default=2.13

manage() {
    local candidate=$1
    shift
    for wanted in "$@"; do
        [[ -d "$HOME/.sdkman/candidates/$candidate/$wanted" ]] && continue
        sdk install "$candidate" "$wanted"
    done
    for installed in "$HOME/.sdkman/candidates/$candidate"/*; do
        [[ -L "$installed" ]] && continue
        installed=$(basename "$installed")
        bs_array_contains "$installed" "$@" || sdk uninstall "$candidate" "$installed"
    done
}

manage_java() {
    local versions
    versions="$(sdk list java | awk '{print $(NF)}' | \
        grep "\-$java_dist$" | grep -v "\.fx-$java_dist" | \
        sort --version-sort)"
    local matches=()
    local default
    for v in "${java_versions[@]}"; do
        local match
        match=$(echo "$versions" | grep "^$v\." || true)
        [[ -z "$match" ]] && bs_fatal "Java $v $java_dist not found"
        match=$(echo "$match" | tail -n 1)
        matches+=("$match")
        [[ "$v" == "$java_default" ]] && default="$match"
    done
    manage java "${matches[@]}"
    sdk default java "$default"
}

manage_scala() {
    local versions
    versions="$(sdk list scala | tr ' ' '\n' | grep '^[0-9]' | sort --version-sort)"
    local matches=()
    local default
    for v in "${scala_versions[@]}"; do
        local match
        match=$(echo "$versions" | grep "^$v\." || true)
        [[ -z "$match" ]] && bs_fatal "Scala $v not found"
        match=$(echo "$match" | tail -n 1)
        matches+=("$match")
        [[ "$v" == "$scala_default" ]] && default="$match"
    done
    manage scala "${matches[@]}"
    sdk default scala "$default"
}

manage_candidates() {
    for candidate in "$HOME/.sdkman/candidates"/*; do
        candidate=$(basename "$candidate")
        if [[ "$candidate" == "java" ]] || [[ "$candidate" == "scala" ]]; then
            continue
        fi
        sdk upgrade "$candidate"
        local current
        current=$(basename "$(readlink -f "$HOME/.sdkman/candidates/$candidate/current")")
        manage "$candidate" "$current"
    done
}

bs_sed_i 's/sdkman_auto_answer=false/sdkman_auto_answer=true/g' "$HOME/.sdkman/etc/config"
set +u
# shellcheck source=/dev/null
source "$HOME/.sdkman/bin/sdkman-init.sh"

sdk update
manage_java
manage_scala
manage_candidates

bs_sed_i 's/sdkman_auto_answer=true/sdkman_auto_answer=false/g' "$HOME/.sdkman/etc/config"
