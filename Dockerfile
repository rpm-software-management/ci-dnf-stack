# Example Usage:
# $ podman build --build-arg TYPE=distro -t ci-dnf-stack -f Dockerfile
# $ podman run --net none -it ci-dnf-stack behave dnf

ARG BASE=fedora:33
FROM $BASE

ENV LANG C.UTF-8
ARG TYPE=nightly
ARG OSVERSION=fedora__33

# disable deltas and weak deps
RUN set -x && \
    echo -e "deltarpm=0" >> /etc/dnf/dnf.conf && \
    echo -e "install_weak_deps=0" >> /etc/dnf/dnf.conf

# enable the test-utils repo
RUN set -x && \
    dnf -y install dnf-plugins-core; \
    dnf -y copr enable rpmsoftwaremanagement/test-utils;

# enable nightlies if requested
RUN set -x && \
    if [ "$TYPE" == "nightly" ]; then \
        dnf -y copr enable rpmsoftwaremanagement/dnf-nightly; \
    fi

# upgrade all packages
RUN set -x && \
    dnf -y --refresh upgrade

# install the test environment and additional packages
RUN set -x && \
    dnf -y install \
        # behave and test requirements
        attr \
        fakeuname \
        findutils \
        glibc-langpack-en \
        libfaketime \
        openssl \
        python3-behave \
        python3-pexpect \
        python3-pip \
        rpm-build \
        rpm-sign \
        sqlite \
        # install debugging tools
        less \
        openssh-clients \
        procps-ng \
        psmisc \
        strace \
        tcpdump \
        vim-enhanced \
        vim-minimal \
        wget \
        # install dnf stack
        createrepo_c \
        dnf \
        yum \
        dnf-plugins-core \
        dnf-utils \
        dnf-automatic \
        # all plugins with the same version as dnf-utils
        $(dnf repoquery dnf-utils --latest-limit=1 -q --qf="python*-dnf-plugin-*-%{version}-%{release}") \
        # extras plugins that are being tested
        python3-dnf-plugin-system-upgrade \
        libdnf \
        microdnf \
        # install third party plugins
        dnf-plugin-swidtags \
        zchunk && \
    pip install 'pyftpdlib'

# install local RPMs if available
COPY ./rpms/ /opt/behave/rpms/
RUN rm /opt/behave/rpms/*-{devel,debuginfo,debugsource}*.rpm; \
    if [ -n "$(find /opt/behave/rpms/ -maxdepth 1 -name '*.rpm' -print -quit)" ]; then \
        dnf -y install /opt/behave/rpms/*.rpm --disableplugin=local; \
    fi

# copy test suite
COPY ./dnf-behave-tests/ /opt/behave/

# set os userdata for behave
RUN echo -e "\
[behave.userdata]\n\
destructive=yes\n\
os=$OSVERSION" > /opt/behave/behave.ini

RUN set -x && \
    rm -rf "/opt/behave/fixtures/certificates/testcerts/" && \
    rm -rf "/opt/behave/fixtures/gpgkeys/keys/" && \
    rm -rf "/opt/behave/fixtures/repos/"

# build test repos from sources
RUN set -x && \
    cd /opt/behave/fixtures/specs/ && \
    ./build.sh --force-rebuild

WORKDIR /opt/behave
