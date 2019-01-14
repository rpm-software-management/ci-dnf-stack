#!/bin/bash


export LC_ALL=C

set -e

DIR=$(dirname $(readlink -f $0))
ARCH="x86_64"
REPODIR="$DIR/../repos"
GROUPS_FILENAME="comps.xml"
rm -rf "$REPODIR"
mkdir -p "$REPODIR"

for path in $DIR/*/*.spec; do
    REPO=$(basename $(dirname $path))
    echo "Building $path..."
    rpmbuild --quiet --target=$ARCH -ba --nodeps --define "_srcrpmdir $REPODIR/$REPO/src" --define "_rpmdir $REPODIR/$REPO" $path
done

for path in $REPODIR/*; do
    REPO=$(basename $path)
    echo "Creating repo $path..."
    pushd $path
    ARGS="--no-database"
    if [ -f ../../specs/$REPO/$GROUPS_FILENAME ]; then
        ARGS="$ARGS --groupfile ../../specs/$REPO/$GROUPS_FILENAME"
    fi
    createrepo_c $ARGS .
    popd
done

echo "DONE: Test data created"
