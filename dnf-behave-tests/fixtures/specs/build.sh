#!/bin/bash


export LC_ALL=C

set -e

DIR=$(dirname $(readlink -f $0))
ARCH="x86_64"
DIST=".fc29"
REPODIR="$DIR/../repos"
GPGDIR="$DIR/../gpgkeys"
CERTSDIR="$DIR/../certificates"
GROUPS_FILENAME="comps.xml"
UPDATEINFO_FILENAME="updateinfo.xml"
MODULES_FILENAME="modules.yaml"
FORCE_REBUILD=

fatal()
{
    printf >&2 "Error: %s\n" "$*"
    exit 1
}

while [ "$1" != "" ]; do
    case "$1" in
        -f|--force-rebuild) FORCE_REBUILD="true"; shift;;
        *) fatal "Non-implemented option: $1"
    esac
done

if [ "$FORCE_REBUILD" = true ]; then
    # remove all generated content
    find $DIR -name *.sha256 -delete
    rm -rf "$REPODIR"
fi

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

        # make lz4 multilib
        if [[ "$SPEC_NAME" =~ "multilib" ]]; then
            rpmbuild --quiet --target=i686 -ba --nodeps --define "_srcrpmdir $REPODIR/$REPO/src" --define "_rpmdir $REPODIR/$REPO" --define "dist $DIST" $path
        fi

        pushd "$SPEC_DIR" > /dev/null
        echo "Spec has changed, writing new checksum: $path"
        sha256sum $(basename $path) > $CSUM_FILE
        popd > /dev/null
    fi

done

${GPGDIR}/sign.sh
${DIR}/break-packages.sh

for path in $REPODIR/*; do
    REPO=$(basename $path)
    echo "Creating repo $path..."
    pushd $path
    ARGS="--no-database --simple-md-filenames --revision=1550000000"
    if [ -f ../../specs/$REPO/$GROUPS_FILENAME ]; then
        ARGS="$ARGS --groupfile ../../specs/$REPO/$GROUPS_FILENAME"
    fi
    createrepo_c $ARGS .
    if [ -f ../../specs/$REPO/$UPDATEINFO_FILENAME ]; then
        modifyrepo_c ../../specs/$REPO/$UPDATEINFO_FILENAME ./repodata
    fi
    if [ -f ../../specs/$REPO/$MODULES_FILENAME ]; then
        modifyrepo_c --mdtype=modules ../../specs/$REPO/$MODULES_FILENAME ./repodata
    fi
    popd
done

${CERTSDIR}/generate_certificates.sh

echo "DONE: Test data created"
