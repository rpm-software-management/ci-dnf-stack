#!/bin/bash
set -xe

DIR=$(dirname $(readlink -f $0))
REPODIR="$DIR/../repos"
SPECS="$DIR/../specs"

rm -r ${DIR}/keys || true
mkdir ${DIR}/keys

for KEY_NAME in $(ls ${DIR}/keyspecs); do
    KEY_DIR="${DIR}/keys/${KEY_NAME}"
    mkdir ${KEY_DIR}

    # create key (without password, without expire)
    HOME=${KEY_DIR} gpg2 --batch --passphrase '' --quick-gen-key ${KEY_NAME} default default 0

    # export public and private key
    HOME=${KEY_DIR} gpg2 --export -a ${KEY_NAME} > "${KEY_DIR}/${KEY_NAME}-public"
    HOME=${KEY_DIR} gpg2 --export-secret-keys -a ${KEY_NAME} > "${KEY_DIR}/${KEY_NAME}-private"

    # create .rpmmacros
    cat > "${KEY_DIR}/.rpmmacros" <<EOF
%_signature gpg
%_gpg_name ${KEY_NAME}
EOF

    # sign packages
    for package in $(cat "${DIR}/keyspecs/${KEY_NAME}"); do
        HOME=${KEY_DIR} rpm --addsign "${REPODIR}/${package}"
    done
done

