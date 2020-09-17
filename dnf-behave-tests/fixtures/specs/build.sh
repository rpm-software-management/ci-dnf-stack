#!/bin/bash


export LC_ALL=C

set -e

DIR="$(dirname "$(readlink -f "$0")")"
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
    find "$DIR" -name "*.sha256" -delete
    rm -rf "$REPODIR"
fi

mkdir -p "$REPODIR"

for path in "$DIR"/*/*.spec; do
    REPO="$(basename "$(dirname "$path")")"
    SPEC_NAME=$(basename "$path")
    SPEC_DIR=$(dirname "$path")
    CSUM_FILE="$SPEC_NAME.sha256"
    CSUM_CHANGED=0

    # detect spec change -> force rebuild
    pushd "$SPEC_DIR" > /dev/null
    if [ -f "$CSUM_FILE" ]; then
        sha256sum -c --status "$CSUM_FILE" || CSUM_CHANGED=1
    else
        CSUM_CHANGED=1
    fi
    popd > /dev/null

    RPMBUILD_CMD="rpmbuild --quiet -ba --nodeps"
    RPMBUILD_CMD="$RPMBUILD_CMD --define='_srcrpmdir $REPODIR/$REPO/src' --define='_rpmdir $REPODIR/$REPO'"
    RPMBUILD_CMD="$RPMBUILD_CMD --define='dist $DIST'"
    RPMBUILD_CMD="$RPMBUILD_CMD --define '_source_payload w1.gzdio' --define '_binary_payload w1.gzdio'"

    # rebuild changed or new specs
    if [ $CSUM_CHANGED -eq 1 ]; then
        echo "Building $path..."
        eval "$RPMBUILD_CMD" --target=$ARCH "'$path'"

        # In addition to default $ARCH (x86_64) also build packages with architectures
        # whose names are contained in the specfile name
        if [[ "$SPEC_NAME" =~ "i686" ]]; then
            eval "$RPMBUILD_CMD" --target=i686 "'$path'"
        fi

        if [[ "$SPEC_NAME" =~ "i386" ]]; then
            eval "$RPMBUILD_CMD" --target=i386 "'$path'"
        fi

        if [[ "$SPEC_NAME" =~ "ppc64" ]]; then
            eval "$RPMBUILD_CMD" --target=ppc64 "'$path'"
        fi

        pushd "$SPEC_DIR" > /dev/null
        echo "Spec has changed, writing new checksum: $path"
        sha256sum "$(basename "$path")" > "$CSUM_FILE"
        popd > /dev/null
    fi

done

"${GPGDIR}/sign.sh"
"${DIR}/break-packages.sh"
"${CERTSDIR}/generate_certificates.sh"

echo "DONE: Test data created"
