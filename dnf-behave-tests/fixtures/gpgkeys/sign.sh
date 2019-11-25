#!/bin/bash
set -xe

DIR=$(dirname $(readlink -f $0))
REPODIR="$DIR/../repos"
SPECS="$DIR/../specs"

rm -r ${DIR}/keys || true
mkdir ${DIR}/keys

for KEY_NAME in $(ls ${DIR}/keyspecs); do

    # set defaults
    USE_SIGN_SUBKEY=0
    USE_NOEOF_KEYS=0

    # read config file for key
    if [ -f "${DIR}/keyspecs/${KEY_NAME}/config" ]; then
        . "${DIR}/keyspecs/${KEY_NAME}/config"
    fi

    KEY_DIR="${DIR}/keys/${KEY_NAME}"
    mkdir ${KEY_DIR}

    # create key (without password, without expire)
    HOME=${KEY_DIR} gpg2 --batch --passphrase '' --quick-gen-key ${KEY_NAME} default default 0

    if [ "${USE_SIGN_SUBKEY}" = "1" ]; then
        # add sign subkey
        KEY_ID=$(HOME=${KEY_DIR} gpg2 --list-keys --with-colons ${KEY_NAME}  | grep '^fpr:' | head -n 1 | cut -d : -f 10)
        HOME=${KEY_DIR} gpg2 --batch --passphrase '' --quick-add-key ${KEY_ID} default sign 0
    fi

    # export public and private key
    HOME=${KEY_DIR} gpg2 --export -a ${KEY_NAME} > "${KEY_DIR}/${KEY_NAME}-public"
    HOME=${KEY_DIR} gpg2 --export-secret-keys -a ${KEY_NAME} > "${KEY_DIR}/${KEY_NAME}-private"

    if [ "${USE_NOEOF_KEYS}" = "1" ]; then
      # remove EOF from keyfiles
      truncate -s -1 "${KEY_DIR}/${KEY_NAME}-public"
      truncate -s -1 "${KEY_DIR}/${KEY_NAME}-private"
    fi

    # create .rpmmacros
    cat > "${KEY_DIR}/.rpmmacros" <<EOF
%_signature gpg
%_gpg_name ${KEY_NAME}
EOF

    # sign packages
    for package in $(cat "${DIR}/keyspecs/${KEY_NAME}/packages"); do
        HOME=${KEY_DIR} rpm --addsign "${REPODIR}/${package}"
    done
done

