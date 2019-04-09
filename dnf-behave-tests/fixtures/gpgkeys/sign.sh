#!/bin/bash
set -xe

DIR=$(dirname $(readlink -f $0))
REPODIR="$DIR/../repos"
SPECS="$DIR/../specs"

pushd ${DIR}
for KEY_NAME in $(ls -d */ | sed 's#/##'); do
    # import public and private key
    HOME=${KEY_NAME} gpg2 --import "${KEY_NAME}/${KEY_NAME}-public"
    HOME=${KEY_NAME} gpg2 --import "${KEY_NAME}/${KEY_NAME}-private"

    # sign packages
    for package in $(cat "${KEY_NAME}/signed-packages"); do
        HOME=${KEY_NAME} rpm --addsign "${REPODIR}/${package}"
    done
done

