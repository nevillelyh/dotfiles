#!/bin/bash

set -euo pipefail

links() {
    url=$1
    curl -fsSL "$url" | grep -o 'href="[^"]\+"' | sed 's/href="\([^"]*\)"/\1/'
}

download() {
    (( ttl = 7 * 24 * 60 * 60 ))
    (( age = ttl + 1 ))
    [[ -f "$file" ]] && age=$(echo "$(date "+%s")" - "$(date -r "$file" "+%s")" | bc -l)
    if [[ $age -ge $ttl ]]; then
        curl -fsSL "$(latest)" -o "$file"
        chmod +x "$file"
    fi
}

run_b2() {
    latest() {
        os=$(uname -s | tr "[:upper:]" "[:lower:]")
        echo "https://github.com/Backblaze/B2_Command_Line_Tool/releases/latest/download/b2-$os"
    }
    file="$HOME/.local/libexec/b2"
    download
    "$file" "$@"
}

run_presto-cli() {
    latest() {
        js_url=https://prestodb.io/static/js/version.js
        version="$(curl -fsSL "$js_url" | grep "\<presto_latest_presto_version\>" | sed "s/[^']*'\([^']*\)';/\1/")"
        echo "https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$version/presto-cli-$version-executable.jar"
    }
    file="$HOME/.local/libexec/presto-cli"
    download
    "$file" "$@"
}

run_trino-cli() {
    latest() {
        links "https://trino.io/download.html" | grep "trino-cli-[0-9]\+-executable.jar"
    }
    file="$HOME/.local/libexec/trino-cli"
    download
    "$file" "$@"
}

bin="$(basename "$0")"
"run_$bin" "$@"
