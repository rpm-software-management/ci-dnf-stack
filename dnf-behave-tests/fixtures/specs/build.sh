#!/bin/bash


export LC_ALL=C

set -e

DIR=$(dirname $(readlink -f $0))
ARCH="x86_64"
DIST=".fc29"
REPODIR="$DIR/../repos"
GROUPS_FILENAME="comps.xml"
UPDATEINFO_FILENAME="updateinfo.xml"
rm -rf "$REPODIR"
mkdir -p "$REPODIR"

for path in $DIR/*/*.spec; do
    REPO=$(basename $(dirname $path))
    echo "Building $path..."
    rpmbuild --quiet --target=$ARCH -ba --nodeps --define "_srcrpmdir $REPODIR/$REPO/src" --define "_rpmdir $REPODIR/$REPO" --define "dist $DIST" $path
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
    if [ -f ../../specs/$REPO/$UPDATEINFO_FILENAME ]; then
        modifyrepo ../../specs/$REPO/$UPDATEINFO_FILENAME ./repodata
    fi
    popd
done

echo "DONE: Test data created"
