#!/bin/bash

set -o pipefail
set -e

LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)"
TOOLS="$(basename "${BASH_SOURCE[0]}")"
JAR="$(find "$LIB" -name "$TOOLS-*.jar" | head -n 1)"

java -jar "$JAR" $@
