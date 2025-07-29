#!/usr/bin/env bash
set -exuo pipefail

if [ "$TMT_REBOOT_COUNT" -eq 0 ]; then
    BOOTC_TEMPDIR=$(mktemp -d)
    trap 'rm -rf -- "$BOOTC_TEMPDIR"' EXIT

    # Get OS info
    source /etc/os-release
    case "$ID" in
        "centos")
            BASE_IMAGE="${BASE_IMAGE:-quay.io/centos-bootc/centos-bootc:stream${VERSION_ID}}"
            ;;
        "fedora")
            BASE_IMAGE="${BASE_IMAGE:-quay.io/fedora/fedora-bootc:${VERSION_ID}}"
            ;;
        "rhel")
            BASE_IMAGE="${BASE_IMAGE:-images.paas.redhat.com/testingfarm/rhel-bootc:${VERSION_ID}}"
    esac

    # TMT needs this key
    cp -r /root/.ssh "$BOOTC_TEMPDIR"

    # Running on Testing Farm
    if [[ -d "/var/ARTIFACTS" ]]; then
        cp -r /var/ARTIFACTS "$BOOTC_TEMPDIR"
    # Running on local machine with tmt run
    else
        cp -r /var/tmp/tmt "$BOOTC_TEMPDIR"
    fi

    # Some rhts-*, rstrnt-* and tmt-* commands are in /usr/local/bin
    cp -r /usr/local/bin "$BOOTC_TEMPDIR"

    # Check image building folder content
    ls -al "$BOOTC_TEMPDIR"

    pushd "$TMT_TREE"
        if [ -e /etc/yum.repos.d/tag-repository.repo ]; then
            cp -v /etc/yum.repos.d/tag-repository.repo repos.d/
        fi

        if [ -e /etc/yum.repos.d/test-artifacts.repo ]; then
            mkdir -p rpms
            dnf repoquery --repo=test-artifacts --qf "%{SOURCERPM} %{NAME}" > T-A-pkgs.pkglist
            cat T-A-pkgs.pkglist
            set +e # following grep would fail whole script on first non-match
            for P in dnf libdnf libsolv librepo librhsm libmodulemd1 libmodulemd microdnf createrepo_c; do
                grep ^$P T-A-pkgs.pkglist | while read line ; do
                    echo $line | awk '{print $2}' >> T-A-Packages
                done
            done
            set -e
            cat T-A-Packages
            dnf download --destdir rpms/ --disablerepo=\* --enablerepo=test-artifacts `cat T-A-Packages | xargs echo -n`
        fi

        ./container-test \
        --container localhost/dnf-bot/dnf-testing-bootc:latest \
        build \
        --file ./bootc/Containerfile \
        --base "$BASE_IMAGE" \
        ${PACKIT_COPR_PROJECT:+--container-arg="--env=COPR=$PACKIT_COPR_PROJECT"} \
        ${PACKIT_COPR_PROJECT:+--container-arg="--env=COPR_RPMS=$PACKIT_COPR_RPMS"}
    popd

    CONTAINERFILE="$BOOTC_TEMPDIR/Containerfile"

    tee "$CONTAINERFILE" > /dev/null << REALEOF
FROM localhost/dnf-bot/dnf-testing-bootc:latest

RUN <<EORUN
set -xeuo pipefail

# For testing farm
mkdir -p -m 0700 /var/roothome

# Enable ttyS0 console
mkdir -p /usr/lib/bootc/kargs.d/
cat <<KARGEOF >> /usr/lib/bootc/kargs.d/20-console.toml
kargs = ["console=ttyS0,115200n8"]
KARGEOF

# cloud-init and rsync are required by TMT
dnf -y install cloud-init rsync
ln -s ../cloud-init.target /usr/lib/systemd/system/default.target.wants
dnf -y clean all

rm -rf /var/cache /var/lib/dnf
EORUN

# Some rhts-*, rstrnt-* and tmt-* commands are in /usr/local/bin
COPY bin /usr/local/bin

# In Testing Farm, all ssh things should be reserved for ssh command run after reboot
COPY .ssh /var/roothome/.ssh
REALEOF

    if [[ -d "/var/ARTIFACTS" ]]; then
        # In Testing Farm, TMT work dir /var/ARTIFACTS should be reserved
        echo "COPY ARTIFACTS /var/ARTIFACTS" >> "$CONTAINERFILE"
    else
        # In local machine, TMT work dir /var/tmp/tmt should be reserved
        echo "COPY tmt /var/tmp/tmt" >> "$CONTAINERFILE"
    fi

    podman build --retry 5 --retry-delay 5s --tls-verify=false -t localhost/dnf-bot/dnf-testing-bootc-tmt:latest -f "$CONTAINERFILE" "$BOOTC_TEMPDIR"
    
    podman images
    podman run \
        --rm \
        --tls-verify=false \
        --privileged \
        --pid=host \
        -v /:/target \
        -v /dev:/dev \
        -v /var/lib/containers:/var/lib/containers \
        -v /root/.ssh:/output \
        --security-opt label=type:unconfined_t \
        localhost/dnf-bot/dnf-testing-bootc-tmt:latest \
        bootc install to-existing-root --target-transport containers-storage --acknowledge-destructive

    tmt-reboot
elif [ "$TMT_REBOOT_COUNT" -eq 1 ]; then
    # Some simple and fast checks
    bootc status
    echo "$PATH"
    printenv
    if [[ -d "/var/ARTIFACTS" ]]; then
        ls -al /var/ARTIFACTS
    else
        ls -al /var/tmp/tmt
    fi
    ls -al /usr/local/bin
    echo "Bootc system on TMT/TF runner"

    exit 0
fi
