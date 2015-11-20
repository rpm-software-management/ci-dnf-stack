FROM fedora:23
MAINTAINER Jaroslav Mracek <jmracek@redhat.com>

RUN dnf -y --setopt=deltarpm=false upgrade rpm libsolv\
  && dnf -y --setopt=deltarpm=false install dnf-plugins-core httpd python-behave

COPY repo /var/www/html/repo/

ADD httpd.conf /etc/httpd/conf/

ADD launch-test /usr/bin/

RUN mkdir -p /temp/dnf.repo

VOLUME /repo

ENTRYPOINT ["launch-test"]
