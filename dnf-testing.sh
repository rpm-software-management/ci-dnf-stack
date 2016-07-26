#!/bin/bash
set -euo pipefail

PROG_PATH=$(dirname $(readlink -f -- $0))

fatal()
{
    printf >&2 "Error: %s\n" "$*"
    exit 1
}

show_usage()
{
    printf >&2 "Try \`$0 --help' for more information.\n"
    exit 1
}

show_help()
{
    cat << EOF
$0 - functional tests for DNF.

Usage: $0 [OPTIONS...] {COMMAND}

Options:
  -h, --help          Show this help

Commands:
  list                List of available functional tests
  build               Build container with functional tests
  run IMAGE [TEST...] Run one or more functional tests

EOF
    exit 0
}

TEMP=$(getopt -n $0 -o h -l help -- "$@") || show_usage
eval set -- "$TEMP"

while :; do
    case "$1" in
        --) shift; break;;
        -h|--help) show_help;;
        *) fatal "Non-implemented option: $1"
    esac
done

action=
for arg; do
    case "$arg" in
        list) action="list";;
        build) action="build";;
        run) action="run";;
        *) fatal "Unknown argument: $arg";;
    esac
    shift
    break
done
[ "$action" != "" ] || fatal "Specify command to do."
if [ "$action" = "run" ]; then
    IMAGE=
    [ $# -gt 0 ] && { IMAGE="$1"; shift; } || fatal "Missing image name."
    TESTS=()
    for arg; do
        TESTS+=("$arg")
        shift
    done
fi
[ $# -eq 0 ] || fatal "Too many arguments."

FEATURES=()
gather_tests()
{
    local glob="$PROG_PATH/dnf-docker-test/features/*.feature"
    local i=0
    for f in $glob; do
        if [ "$f" = "$glob" ]; then
            fatal "Can't find behave features."
        fi
        local feature=$(basename "$f")
        FEATURES+=("${feature%.feature}")
    done
}
gather_tests

list()
{
    printf "%s\n" "${FEATURES[@]}"
    exit 0
}
[ "$action" = "list" ] && list

build()
{
    local output=($(sudo docker build --no-cache --force-rm "$PROG_PATH" | \
        tee >(cat - >&2) | tail -1))
    if [ ${#output[@]} -eq 3 ] && \
       [ "${output[0]}" = "Successfully" ] && 
       [ "${output[1]}" = "built" ]; then
        printf "%s\n" "${output[2]}"
    else
        fatal "Failed to parse output."
    fi
    exit 0
}
[ "$action" = "build" ] && build

run()
{
    [ ${#TESTS[@]} -eq 0 ] && TESTS=("${FEATURES[@]}")
    local failed=0
    for feature in "${TESTS[@]}"; do
        sudo docker run --rm "$IMAGE" launch-test "$feature" dnf >&2 || :
        [ $? -ne 0 ] && let ++failed
    done
    exit $failed
}
[ "$action" = "run" ] && run
