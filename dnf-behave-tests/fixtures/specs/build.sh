#!/bin/bash


export LC_ALL=C

set -e

DIR=$(dirname $(readlink -f $0))
ARCH="x86_64"
DIST=".fc29"
REPODIR="$DIR/../repos"
GROUPS_FILENAME="comps.xml"
UPDATEINFO_FILENAME="updateinfo.xml"
MODULES_FILENAME="modules.yaml"
mkdir -p "$REPODIR"

for path in $DIR/*/*.spec; do
    REPO=$(basename $(dirname $path))
    SPEC_NAME=$(basename $path)
    SPEC_DIR=$(dirname $path)
    CSUM_FILE="$SPEC_NAME.sha256"
    CSUM_CHANGED=0

    # detect spec change -> force rebuild
    pushd "$SPEC_DIR" > /dev/null
    if [ -f "$CSUM_FILE" ]; then
        sha256sum -c --status $CSUM_FILE || CSUM_CHANGED=1
    else
        CSUM_CHANGED=1
    fi
    popd > /dev/null

    # rebuild changed or new specs
    if [ $CSUM_CHANGED -eq 1 ]; then
        echo "Building $path..."
        rpmbuild --quiet --target=$ARCH -ba --nodeps --define "_srcrpmdir $REPODIR/$REPO/src" --define "_rpmdir $REPODIR/$REPO" --define "dist $DIST" $path

        pushd "$SPEC_DIR" > /dev/null
        echo "Spec has changed, writing new checksum: $path"
        sha256sum $(basename $path) > $CSUM_FILE
        popd > /dev/null
    fi
done

for path in $REPODIR/*; do
    REPO=$(basename $path)
    echo "Creating repo $path..."
    pushd $path
    ARGS="--no-database --simple-md-filenames --revision=1550000000 --set-timestamp-to-revision"
    if [ -f ../../specs/$REPO/$GROUPS_FILENAME ]; then
        ARGS="$ARGS --groupfile ../../specs/$REPO/$GROUPS_FILENAME"
    fi
    createrepo_c $ARGS .
    if [ -f ../../specs/$REPO/$UPDATEINFO_FILENAME ]; then
        modifyrepo ../../specs/$REPO/$UPDATEINFO_FILENAME ./repodata
    fi
    if [ -f ../../specs/$REPO/$MODULES_FILENAME ]; then
        modifyrepo --mdtype=modules ../../specs/$REPO/$MODULES_FILENAME ./repodata
    fi
    popd
done

echo "DONE: Test data created"
