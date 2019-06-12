#!/bin/bash
set -xeuo pipefail

OWNER="rpmsoftwaremanagement"
PROJECT="dnf-nightly"
CHROOTS=(
          "fedora-30-x86_64"
          "fedora-29-x86_64"
          "fedora-rawhide-x86_64"
          #"epel-7-x86_64"
          )

run_build(){
    overlaydir="dnf-master"
    if [[ $chroot == epel-* ]] ; then
        overlaydir="$overlaydir-epel7"
    fi
    gitdir=$(mktemp -d tmp_nightlies.XXXXXXXX --tmpdir)
    rpm-gitoverlay --gitdir "$gitdir" --log DEBUG build-overlay -s ../overlays/$overlaydir rpm copr --chroot "$1" --owner $OWNER --project $PROJECT
    rm -rf "$gitdir"
}

pushd $(dirname $(readlink -f $0))
    for chroot in "${CHROOTS[@]}"; do
        run_build "$chroot" &
    done
popd

wait

echo "Done."
