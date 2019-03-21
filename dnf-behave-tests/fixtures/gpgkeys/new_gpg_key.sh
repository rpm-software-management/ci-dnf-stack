#!/bin/bash
set -e

if [ $# -ne 1 ]; then
    echo "Need argument: key-name"
    exit 1
fi

KEY_NAME=$1
DIR=$(dirname $(readlink -f $0))
KEY_DIR="${DIR}/${KEY_NAME}"

mkdir ${KEY_DIR}

# create key (without password, without expire)
HOME=${KEY_DIR} gpg2 --batch --passphrase '' --quick-gen-key ${KEY_NAME} default default 0

# export public key
HOME=${KEY_DIR} gpg2 --export -a ${KEY_NAME} > "${KEY_DIR}/${KEY_NAME}-public"

# create .rpmmacros
cat > "${KEY_DIR}/.rpmmacros" <<EOF
%_signature gpg
%_gpg_name ${KEY_NAME}
EOF

touch "${KEY_DIR}/signed-packages"

