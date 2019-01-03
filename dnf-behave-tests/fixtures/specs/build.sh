#!/bin/bash


export LC_ALL=C

set -e

DIR=$(dirname $(readlink -f $0))
ARCH="x86_64"
REPODIR="$DIR/../repos"
rm -rf "$REPODIR"
mkdir -p "$REPODIR"

for path in $DIR/*/*.spec; do
    REPO=$(basename $(dirname $path))
    echo "Building $path..."
    rpmbuild --quiet --target=$ARCH -ba --nodeps --define "_srcrpmdir $REPODIR/$REPO/src" --define "_rpmdir $REPODIR/$REPO" $path
done

for path in $REPODIR/*; do
    echo "Creating repo $path..."
    pushd $path
    createrepo_c --no-database .
    popd
done

echo "DONE: Test data created"
