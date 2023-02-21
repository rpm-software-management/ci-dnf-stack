# Example Usage:
# $ podman build --build-arg TYPE=distro -t ci-dnf-stack -f Dockerfile
# $ podman run --net none -it ci-dnf-stack behave dnf

ARG BASE=fedora:38
FROM $BASE

ENV LANG C.UTF-8
ARG TYPE=nightly

# disable deltas and weak deps
RUN set -x && \
    echo -e "deltarpm=0" >> /etc/dnf/dnf.conf && \
    echo -e "install_weak_deps=0" >> /etc/dnf/dnf.conf

# Copy extra repo files
COPY ./repos.d/ /etc/yum.repos.d/

# enable the test-utils repo
RUN set -x && \
    dnf -y --refresh upgrade; \
    dnf -y install dnf-plugins-core; \
    dnf -y copr enable rpmsoftwaremanagement/test-utils;

# enable dnf5
RUN set -x && \
    dnf -y copr enable rpmsoftwaremanagement/dnf5-unstable; \
    #  enable dnf-nightly as well to get librepo and libsolv
    dnf -y copr enable rpmsoftwaremanagement/dnf-nightly; \
    # run upgrade before distro-sync in case there is a new version in dnf-nightly that has a new dependency
    dnf -y upgrade; \
    dnf -y distro-sync --repo copr:copr.fedorainfracloud.org:rpmsoftwaremanagement:dnf5-unstable;

# copy test suite
COPY ./dnf-behave-tests/ /opt/ci/dnf-behave-tests

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
