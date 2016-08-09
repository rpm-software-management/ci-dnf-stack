FROM fedora:24
ENV LANG C

RUN echo "deltarpm=0" >> /etc/dnf/dnf.conf
RUN dnf -y update
RUN dnf -y install httpd /usr/bin/behave-2 python2-rpmfluff
COPY repo /var/www/html/repo/
COPY features /behave/

COPY rpms /rpms/
# TODO: COPR broken, drop --allowerasing
RUN dnf -y install /rpms/*.rpm --allowerasing
RUN dnf -y autoremove
RUN dnf -y clean all
RUN mkdir /tmp/repos.d && mv /etc/yum.repos.d/* /tmp/repos.d/

ADD launch-test /usr/bin/
RUN mkdir /repo

VOLUME ["/junit"]
