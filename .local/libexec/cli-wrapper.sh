#!/bin/bash

# Wrapper for AWS CLI, B2, etc.

set -euo pipefail

case "$(basename "$0")" in
    b2ls)
        cmd=(b2 ls)
        opts=":jlr"
        fn() {
            case "$1" in
                j) echo "--json" ;;
                l) echo "--long" ;;
                r) echo "--recursive" ;;
                ?) echo "" ;;
            esac
        }
        ;;
    s3cp)
        cmd=(aws s3 cp)
        opts=":qr"
        fn() {
            case "$1" in
                q) echo "--quiet" ;;
                r) echo "--recursive" ;;
                ?) echo "" ;;
            esac
        }
        ;;
    s3ls)
        cmd=(aws s3 ls)
        opts=":hrs"
        fn() {
            case "$1" in
                h) echo "--human-readable" ;;
                r) echo "--recursive" ;;
                s) echo "--summarize" ;;
                ?) echo "" ;;
            esac
        }
        ;;
    s3mv)
        cmd=(aws s3 mv)
        opts=":qr"
        fn() {
            case "$1" in
                q) echo "--quiet" ;;
                r) echo "--recursive" ;;
                ?) echo "" ;;
            esac
        }
        ;;
    s3rm)
        cmd=(aws s3 rm)
        opts=":dq"
        fn() {
            case "$1" in
                q) echo "--quiet" ;;
                r) echo "--recursive" ;;
                ?) echo "" ;;
            esac
        }
        ;;
    s3sync)
        cmd=(aws s3 sync)
        opts=":qr"
        fn() {
            case "$1" in
                q) echo "--quiet" ;;
                r) echo "--recursive" ;;
                ?) echo "" ;;
            esac
        }
        ;;
esac

args=()
while [[ $OPTIND -le $# ]]; do
    curr="${!OPTIND}"
    if [[ "$curr" =~ --[^-].* ]]; then
        args+=("$curr")
        ((OPTIND++))
    else
        if getopts "$opts" opt; then
            arg=$(fn "$opt")
            if [[ -z "$arg" ]]; then
                args+=("$curr")
                ((OPTIND++))
            else
                args+=("$arg")
            fi
        else
            args+=("$curr")
            ((OPTIND++))
        fi
    fi
done

"${cmd[@]}" "${args[@]}"
