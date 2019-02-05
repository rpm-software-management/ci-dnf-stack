FROM fedora:29
ENV LANG C


# Build types
# -----------
# distro
#       install distro packages
# copr
#       install distro packages
#       then upgrade to copr packages
# local
#       install distro packages
#       install also additional tools for debugging in the container
#       then upgrade to packages from local rpms/ folder
#
# Example: docker build . --build-arg=TYPE=copr
ARG TYPE=local


# copy copr repo file to make it available for TYPE=local build
COPY ./docker/_copr_rpmsoftwaremanagement-dnf-nightly.repo /opt/behave/data/


RUN set -x && \
    # disable deltas and weak deps
    echo -e "deltarpm=0" >> /etc/dnf/dnf.conf && \
    echo -e "install_weak_deps=0" >> /etc/dnf/dnf.conf && \
    #
    # if TYPE == local, copy the copr repo file to reposdir
    if [ "$TYPE" == "copr" ]; then \
        cp /opt/behave/data/_copr_rpmsoftwaremanagement-dnf-nightly.repo /etc/yum.repos.d/; \
    fi && \
    #
    # upgrade all packages to the latest available versions
    dnf -y --refresh upgrade && \
    #
    # install the test environment and additional packages
    dnf -y install \
        # behave and test requirements
        python3-behave \
        python3-pexpect \
        # if TYPE == local, install debugging tools
        $(if [ "$TYPE" == "local" ]; then \
            echo \
                less \
                openssh-clients \
                strace \
                tcpdump \
                vim-minimal \
                wget \
            ; \
        fi) \
        # install dnf stack
        libdnf \
        dnf \
        dnf-plugins-core \
        microdnf


# if TYPE == local, install local RPMs
COPY ./docker/rpms/ /opt/behave/rpms/
RUN if [ "$TYPE" == "local" ]; then \
        dnf -y install /opt/behave/rpms/*.rpm \
            -x '*-debuginfo' \
            -x '*-debugsource' \
            -x '*plugin-versionlock*' \
            -x '*plugin-local*' \
            -x '*plugin-torproxy*' \
            -x '*plugin-migrate*' \
            ; \
    fi


# copy test suite
COPY ./dnf-behave-tests/ /opt/behave/


VOLUME ["/opt/behave/junit"]


# Run docker:
#
# $ docker run -it <hash> /bin/bash
# $ cd /opt/behave
# $ ./run-tests
#
# or
#
# $ docker run -it <hash> behave -Ddnf_executable=dnf-3 --junit --junit-directory=/opt/behave/junit/ [--wip --no-skipped] /opt/behave/features
# TODO: this doesn't work yet because repos have relative paths to workdir
# probably need to change the relative paths to be relative to repo file
# or replace relative with absolute paths
