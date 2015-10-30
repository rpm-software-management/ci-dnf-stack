FROM fedora:rawhide
MAINTAINER Jaroslav Mracek <jmracek@redhat.com>

RUN dnf -y install dnf-plugins-core

#RUN dnf -y upgrade dnf

RUN dnf -y upgrade rpm

RUN dnf -y upgrade libsolv

RUN dnf -y install httpd python-behave

COPY repo /var/www/html/repo/

ADD httpd.conf /etc/httpd/conf/

ADD launch-test /usr/bin/

RUN mkdir -p /temp/dnf.repo

VOLUME /repo

#RUN echo -ne "[test]\nname=test\nbaseurl=file:///repo\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/test.repo
#RUN echo -ne '[test]\nname=test\nbaseurl=http://127.0.0.1/repo/test-1/\nenabled=1\ngpgcheck=0' > /etc/yum.repos.d/test.repo
#RUN echo -ne "[upgrade_1]\nname=test\nbaseurl=http://127.0.0.1/repo/' + repo + '\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/upgrade_1.repo

#RUN echo -ne "[upgrade_2]\nname=test\nbaseurl=http://127.0.0.1/repo/' + repo + '\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/upgrade_2.repo

ENTRYPOINT ["launch-test"]
