FROM fedora:rawhide
MAINTAINER Jaroslav Mracek <jmracek@redhat.com>

RUN dnf -y upgrade dnf

RUN dnf -y upgrade

RUN dnf -y install httpd python-behave

COPY repo /var/www/html/repo/

ADD httpd.conf /etc/httpd/conf/

ADD launch-test /usr/bin/
VOLUME /repo 

RUN echo -ne "[test]\nname=test\nbaseurl=file:///repo\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/test.repo

ENTRYPOINT ["launch-test"]
