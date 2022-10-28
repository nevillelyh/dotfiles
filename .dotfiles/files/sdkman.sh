#!/bin/bash

# Manage SDKMAN packages

set -euo pipefail

java_versions=(8 11 17)
java_default=17
java_dist="zulu"
scala_versions=(2.13 3)
scala_default=2.13

manage() {
    candidate=$1
    shift
    for wanted in "$@"; do
        [[ -d "$HOME/.sdkman/candidates/$candidate/$wanted" ]] && continue
        sdk install "$candidate" "$wanted"
    done
    for installed in "$HOME/.sdkman/candidates/$candidate"/*; do
        [[ -L "$installed" ]] && continue
        installed=$(basename "$installed")
        m=0
        for wanted in "$@"; do
            [[ "$installed" == "$wanted" ]] && m=1
        done
        if [[ "$m" -eq 0 ]]; then
            sdk uninstall "$candidate" "$installed"
        fi
    done
}

manage_java() {
    versions="$(sdk list java | awk '{print $(NF)}' | \
        grep "\-$java_dist$" | grep -v "\.fx-$java_dist" | \
        sort --version-sort)"
    matches=()
    for v in "${java_versions[@]}"; do
        match=$(echo "$versions" | grep "^$v\." || true)
        if [[ -z "$match" ]]; then
            echo "Java $v $java_dist not found"
            exit 1
        fi
        match=$(echo "$match" | tail -n 1)
        matches+=("$match")
        [[ "$v" == "$java_default" ]] && default="$match"
    done
    manage java "${matches[@]}"
    sdk use java "$default"
}

manage_scala() {
    versions="$(sdk list scala | tr " " "\n" | grep "^[0-9]" | sort --version-sort)"
    matches=()
    for v in "${scala_versions[@]}"; do
        match=$(echo "$versions" | grep "^$v\." || true)
        if [[ -z "$match" ]]; then
            echo "Scala $v not found"
            exit 1
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
        current=$(basename "$(readlink -f "$HOME/.sdkman/candidates/$candidate/current")")
        manage "$candidate" "$current"
    done
}

sed_i() {
    case "$(uname -s)" in
        Darwin) sed -i '' "$@" ;;
        Linux) sed -i "$@" ;;
    esac
}

sed_i "s/sdkman_auto_answer=false/sdkman_auto_answer=true/g" "$HOME/.sdkman/etc/config"
set +u
source "$HOME/.sdkman/bin/sdkman-init.sh"

manage_java
manage_scala
manage_candidates

sed_i "s/sdkman_auto_answer=true/sdkman_auto_answer=false/g" "$HOME/.sdkman/etc/config"
