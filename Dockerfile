FROM fedora:24
ENV LANG C

RUN dnf -y update
RUN dnf -y install httpd /usr/bin/behave-2
RUN dnf -y autoremove
COPY dnf-docker-test/repo /var/www/html/repo/
COPY dnf-docker-test/features /behave/

COPY rpms /rpms/
# TODO: COPR broken, drop --allowerasing
RUN dnf -y install /rpms/*.rpm --allowerasing
RUN dnf -y clean all
RUN mkdir /tmp/repos.d && mv /etc/yum.repos.d/* /tmp/repos.d/

ADD dnf-docker-test/httpd.conf /etc/httpd/conf/
ADD dnf-docker-test/launch-test /usr/bin/
RUN mkdir /repo

VOLUME ["/junit"]
