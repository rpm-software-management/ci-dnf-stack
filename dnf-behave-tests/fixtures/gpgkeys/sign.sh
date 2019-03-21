#!/bin/bash
set -xe

DIR=$(dirname $(readlink -f $0))
REPODIR="$DIR/../repos"
SPECS="$DIR/../specs"

for KEY_DIR in $(ls -d ${DIR}/*/); do

    # sign packages
    for package in $(cat "${KEY_DIR}signed-packages"); do
        HOME=${KEY_DIR} rpm --addsign "${REPODIR}/${package}"
    done
done

