#!/bin/bash
set -xeuo pipefail

OWNER="rpmsoftwaremanagement"
PROJECT="dnf-nightly"
CHROOTS=(
          "epel-7-x86_64"
          "fedora-28-x86_64"
          "fedora-29-x86_64"
          "fedora-30-x86_64"
          "fedora-rawhide-x86_64"
          )

pushd $(dirname $(readlink -f $0))
    for chroot in "${CHROOTS[@]}"; do
        overlaydir="dnf-master"
        if [[ $chroot == epel-* ]] ; then
            overlaydir="$overlaydir-epel7"
        fi
        rpm-gitoverlay --log DEBUG build-overlay -s ../overlays/$overlaydir rpm copr --chroot "$chroot" --owner $OWNER --project $PROJECT
    done
popd
