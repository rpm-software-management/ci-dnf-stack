# Example Usage:
# $ podman build --build-arg TYPE=distro -t ci-dnf-stack -f Dockerfile
# $ podman run --net none -it ci-dnf-stack behave dnf

ARG BASE=fedora:42
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

# Install DNF4 if not present
RUN set -x && \
    if ! command -v dnf4 2>/dev/null; then \
        dnf5 -y install dnf4; \
    fi

# enable the test-utils repo
RUN set -x && \
    dnf4 -y --refresh upgrade; \
    dnf4 -y install dnf-plugins-core; \
    dnf4 -y copr enable rpmsoftwaremanagement/test-utils;

# enable nightlies if requested
RUN set -x && \
    if [ "$TYPE" == "nightly" ]; then \
        dnf4 -y copr enable rpmsoftwaremanagement/dnf-nightly; \
        dnf4 -y repository-packages copr:copr.fedorainfracloud.org:rpmsoftwaremanagement:dnf-nightly upgrade; \
    fi

RUN set -x && \
    if [ -n "$COPR" ] && [ -n "$COPR_RPMS" ]; then \
       dnf4 -y copr enable $COPR; \
       dnf4 -y install $COPR_RPMS; \
    fi

# copy test suite
COPY ./dnf-behave-tests/ /opt/ci/dnf-behave-tests

# remove dnf5 and exclude it to ensure we test old dnf
RUN set -x && \
    dnf4 -y remove dnf5 --setopt=protected_packages=,; \
    echo "excludepkgs=dnf5*" >> /etc/dnf/dnf.conf

# On Fedora > 40 the symlinks to dnf-3 and yum are missing (because dnf5 provides dnf), add them manually
RUN set -x && \
    ln -sf /usr/bin/dnf-3 /usr/bin/dnf; \
    ln -sf /usr/bin/dnf-3 /usr/bin/yum

# install test suite dependencies
RUN set -x && \
    dnf4 -y builddep /opt/ci/dnf-behave-tests/requirements.spec && \
    pip3 install -r /opt/ci/dnf-behave-tests/requirements.txt

# install local RPMs if available
COPY ./rpms/ /opt/ci/rpms/
RUN set -x && \
    rm /opt/ci/rpms/*-{devel,debuginfo,debugsource}*.rpm; \
    if [ -n "$(find /opt/ci/rpms/ -maxdepth 1 -name '*.rpm' -print -quit)" ]; then \
        dnf4 -y install /opt/ci/rpms/*.rpm --disableplugin=local; \
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
