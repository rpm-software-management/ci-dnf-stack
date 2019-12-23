#!/bin/bash

PROG_PATH=$(dirname $(realpath -s -- $0))

pushd $PROG_PATH > /dev/null

PYTHON=`command -v python3`
if [ -z $PYTHON ]; then
    PYTHON=`command -v python2`
fi
if [ ! $PYTHON ]; then
    printf >&2 "Error: Python interpreter not found.\n"
    exit 1
fi

exec "$PYTHON" container-test "$@"

popd
