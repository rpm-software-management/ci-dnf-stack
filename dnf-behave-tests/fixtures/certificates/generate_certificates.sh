#!/bin/bash
set -e

PROG_PATH="$(dirname "$(readlink -f -- "$0")")"
# shellcheck source=dnf-behave-tests/fixtures/certificates/x509certgen
. "${PROG_PATH}/x509certgen"
rm -rf "$PROG_PATH/testcerts"
mkdir -p "$PROG_PATH/testcerts"
pushd "$PROG_PATH/testcerts"
[ -n "$CIPH1" ] || CIPH1="rsa"
if [ -z "$CIPH2" ] ; then
    # ensure that PQC is supported
    openssl list -signature-algorithms &> openssl.log
    if grep -i mldsa65 openssl.log; then
        CIPH2="mldsa65"
    else
        CIPH2="rsa"
    fi
    rm -f openssl.log
fi
x509KeyGen -t "$CIPH1" ca
x509KeyGen -t "$CIPH1" server
x509KeyGen -t "$CIPH1" client
x509KeyGen -t "$CIPH2" ca2
x509KeyGen -t "$CIPH2" server2
x509KeyGen -t "$CIPH2" client2
x509SelfSign -t ca ca
x509SelfSign -t ca ca2
x509CertSign -t webserver --CA ca server
x509CertSign -t webclient --CA ca client
x509CertSign -t webserver --CA ca2 server2
x509CertSign -t webclient --CA ca2 client2
popd
