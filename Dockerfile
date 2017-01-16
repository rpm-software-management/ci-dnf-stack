FROM fedora:25
ENV LANG C
ARG type=local

COPY dnf-docker-test/repo /var/www/html/repo/
COPY dnf-docker-test/features /behave/
COPY dnf-docker-test/features /tests/
COPY rpms /rpms/

RUN echo -e '\necho "deltarpm=0" >> /etc/dnf/dnf.conf' \
    && echo "deltarpm=0" >> /etc/dnf/dnf.conf \
    # behave: core
    # httpd: old-style repos
    # six: py2/py3
    # enum34: rpmdb State
    # whichcraft: shutil.which() for py2
    # jinja2: rpmspec template
    && echo -e '\ndnf -y install httpd python2-behave python2-six python-enum34 python2-whichcraft python-jinja2 python2-pexpect' \
    && dnf -y install httpd python2-behave python2-six python-enum34 python2-whichcraft python-jinja2 python2-pexpect \
    && if [ $type = "local" ] ; then \
        # Allows to run test with rpms from only single component in rpms/
        echo -e '\ndnf -y install dnf-plugins-core python3-dnf-plugins-core python2-dnf-plugins-core rpm-build createrepo_c' \
        && dnf -y install dnf-plugins-core python3-dnf-plugins-core python2-dnf-plugins-core rpm-build createrepo_c  \
        && echo -e '\ndnf -y copr enable rpmsoftwaremanagement/dnf-nightly' \
        && dnf -y copr enable rpmsoftwaremanagement/dnf-nightly ; \
    fi \
    # prevent installation of dnf-plugins-extras (versionlock, local, torproxy)
    && echo -e '\nrm /rpms/*extras-versionlock*.rpm /rpms/*extras-local*.rpm /rpms/*extras-torproxy*.rpm' \
    && rm /rpms/*extras-versionlock*.rpm /rpms/*extras-local*.rpm /rpms/*extras-torproxy*.rpm || echo "RPMs files do not exist" >&2 \
    && echo -e '\ndnf -y --best upgrade dnf' \
    && dnf -y --best upgrade dnf \
    && echo -e '\nif ls /rpms/*.rpm 1> /dev/null 2>&1; then dnf -y install /rpms/*.rpm; else echo "RPMs files do not exist" >&2; fi' \
    && if ls /rpms/*.rpm 1>/dev/null 2>&1; then dnf -y install /rpms/*.rpm else echo "RPMs files do not exist" >&2; fi \
    && if [ $type = "local" ] ; then \
        # next line is a temporary workaround for RhBug:1398272
        rpm -q dnf \
        && echo -e '\ndnf -y mark install $(dnf repoquery --unneeded -q)' \
        && dnf -y mark install $(dnf repoquery --unneeded -q) ; \
    else \
        echo -e '\ndnf -y autoremove' \
        && dnf -y autoremove ; \
    fi \
    && echo -e '\ndnf -y clean all' \
    && dnf -y clean all \
    && echo -e '\nmkdir /tmp/repos.d && mv /etc/yum.repos.d/* /tmp/repos.d/' \
    && mkdir /tmp/repos.d && mv /etc/yum.repos.d/* /tmp/repos.d/ \
    && echo -e '\nmkdir /repo' \
    && mkdir /repo \
    && echo -e 'rm -f /behave/*.feature' \
    && rm -f /behave/*.feature

ADD dnf-docker-test/launch-test /usr/bin/
ADD dnf-docker-test/report-behave-json /usr/bin/
VOLUME ["/junit"]
