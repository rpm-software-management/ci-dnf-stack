# Example Usage:
# $ podman build --build-arg TYPE=distro -t ci-dnf-stack -f Dockerfile
# $ podman run --net none -it ci-dnf-stack behave dnf

ARG BASE=fedora:40
FROM $BASE

ENV LANG C.UTF-8
ARG TYPE=nightly

# disable deltas and weak deps
RUN set -x && \
    echo -e "deltarpm=0" >> /etc/dnf/dnf.conf && \
    echo -e "install_weak_deps=0" >> /etc/dnf/dnf.conf

# Import extra CA certificates
COPY ./ca-trust/ /etc/pki/ca-trust/source/anchors/
RUN update-ca-trust

# Copy extra repo files
COPY ./repos.d/ /etc/yum.repos.d/

# enable the test-utils repo
RUN set -x && \
    dnf -y --refresh upgrade; \
    dnf -y install dnf-plugins-core; \
    dnf -y copr enable rpmsoftwaremanagement/test-utils;

# enable nightlies if requested
RUN set -x && \
    if [ "$TYPE" == "nightly" ]; then \
        dnf -y copr enable rpmsoftwaremanagement/dnf-nightly; \
        # run upgrade before distro-sync in case there is a new version in dnf-nightly that has a new dependency
        dnf -y upgrade; \
        dnf -y distro-sync --repo copr:copr.fedorainfracloud.org:rpmsoftwaremanagement:dnf-nightly; \
    fi

RUN set -x && \
    if [ -n "$COPR" ] && [ -n "$COPR_RPMS" ]; then \
       dnf -y copr enable $COPR; \
       dnf -y install $COPR_RPMS; \
    fi

# copy test suite
COPY ./dnf-behave-tests/ /opt/ci/dnf-behave-tests

# remove dnf5 and exclude it to ensure we test old dnf
RUN set -x && \
    dnf -y remove dnf5 --setopt=protected_packages=,; \
    echo "excludepkgs=dnf5*" >> /etc/dnf/dnf.conf

# On Fedora > 40 the symlinks to dnf-3 and yum are missing (because dnf5 provides dnf), add them manually
RUN set -x && \
    ln -sf /usr/bin/dnf-3 /usr/bin/dnf; \
    ln -sf /usr/bin/dnf-3 /usr/bin/yum

# install test suite dependencies
RUN set -x && \
    dnf -y builddep /opt/ci/dnf-behave-tests/requirements.spec && \
    pip3 install -r /opt/ci/dnf-behave-tests/requirements.txt

# install local RPMs if available
COPY ./rpms/ /opt/ci/rpms/
RUN rm /opt/ci/rpms/*-{devel,debuginfo,debugsource}*.rpm; \
    if [ -n "$(find /opt/ci/rpms/ -maxdepth 1 -name '*.rpm' -print -quit)" ]; then \
        dnf -y install /opt/ci/rpms/*.rpm --disableplugin=local; \
    fi

# create directory for dbus daemon socket
RUN set -x && \
    mkdir -p /run/dbus

RUN set -x && \
    rm -rf "/opt/ci/dnf-behave-tests/fixtures/certificates/testcerts/" && \
    rm -rf "/opt/ci/dnf-behave-tests/fixtures/gpgkeys/keys/" && \
    rm -rf "/opt/ci/dnf-behave-tests/fixtures/repos/"

# build test repos from sources
RUN set -x && \
    cd /opt/ci/dnf-behave-tests/fixtures/specs/ && \
    ./build.sh --force-rebuild

WORKDIR /opt/ci/dnf-behave-tests
