FROM fedora:24
ENV LANG C

RUN dnf -y update
# TODO: use python2-rpmfluff from repo once it will hit repos
RUN dnf -y install httpd /usr/bin/behave-2 https://kojipkgs.fedoraproject.org//work/tasks/85/14980085/python2-rpmfluff-0.5.1-1.fc24.noarch.rpm
COPY dnf-docker-test/repo /var/www/html/repo/
COPY dnf-docker-test/features /behave/

COPY rpms /rpms/
# TODO: COPR broken, drop --allowerasing
RUN dnf -y install /rpms/*.rpm --allowerasing
RUN dnf -y autoremove
RUN dnf -y clean all
RUN mkdir /tmp/repos.d && mv /etc/yum.repos.d/* /tmp/repos.d/

ADD dnf-docker-test/httpd.conf /etc/httpd/conf/
ADD dnf-docker-test/launch-test /usr/bin/
RUN mkdir /repo

VOLUME ["/junit"]
