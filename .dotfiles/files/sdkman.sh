#!/bin/bash

# Manage SDKMAN packages

set -euo pipefail

if [[ -f "$HOME/.dotfiles/files/bs.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.dotfiles/files/bs.sh"
else
    eval "$(curl -fsSL https://raw.githubusercontent.com/nevillelyh/dotfiles/main/.dotfiles/files/bs.sh)"
fi

java_versions=(8 11 17)
java_default=17
java_dist="zulu"
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
        if [[ "$(bs_array_contains "$installed" "$@")" == "1" ]]; then
            sdk uninstall "$candidate" "$installed"
        fi
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
        if [[ -z "$match" ]]; then
            bs_fatal "Java $v $java_dist not found"
        fi
        match=$(echo "$match" | tail -n 1)
        matches+=("$match")
        [[ "$v" == "$java_default" ]] && default="$match"
    done
    manage java "${matches[@]}"
    sdk use java "$default"
}

manage_scala() {
    local versions
    versions="$(sdk list scala | tr ' ' '\n' | grep '^[0-9]' | sort --version-sort)"
    local matches=()
    local default
    for v in "${scala_versions[@]}"; do
        local match
        match=$(echo "$versions" | grep "^$v\." || true)
        if [[ -z "$match" ]]; then
            bs_fatal "Scala $v not found"
        fi
        match=$(echo "$match" | tail -n 1)
        matches+=("$match")
        [[ "$v" == "$scala_default" ]] && default="$match"
    done
    manage scala "${matches[@]}"
    sdk use scala "$default"
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
