FROM fedora:rawhide
MAINTAINER Jaroslav Mracek <jmracek@redhat.com>

RUN dnf -y install dnf-plugins-core\
  && dnf -y upgrade rpm\
  && dnf -y upgrade libsolv\
  && dnf -y install httpd python-behave

COPY repo /var/www/html/repo/

ADD httpd.conf /etc/httpd/conf/

ADD launch-test /usr/bin/

VOLUME /repo

ENTRYPOINT ["launch-test"]
