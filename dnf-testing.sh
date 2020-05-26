#!/bin/bash

PROG_PATH="$(dirname "$(realpath -s -- "$0")")"

pushd "$PROG_PATH" > /dev/null || return

# first check whether platform-python binary exists (for RHEL8)
if [[ -x "/usr/libexec/platform-python" ]]; then
    PYTHON=/usr/libexec/platform-python
else
    # use python3 with fall back to python2
    PYTHON=$(command -v python3)
    if [ -z "$PYTHON" ]; then
        PYTHON=$(command -v python2)
    fi
fi
if [ ! "$PYTHON" ]; then
    printf >&2 "Error: Python interpreter not found.\n"
    exit 1
fi

"$PYTHON" container-test "$@"

popd || exit
