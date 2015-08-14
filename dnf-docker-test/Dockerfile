FROM fedora:rawhide
MAINTAINER Pavel Odvody <podvody@redhat.com>

ENV PKG_NAME=libsolv-0.6.11-1.fc23.src.rpm

RUN dnf --nogpgcheck -y install dnf-plugins-core\
 && dnf --nogpgcheck -y builddep libsolv\ 
 && dnf --nogpgcheck -y install automake gcc-c++ make rpm-build  wget which

WORKDIR /build/libsolv_src/

ADD libsolv-enable_complex_deps.patch ./
ADD test-suite.py /usr/bin/

RUN dnf --nogpgcheck -y upgrade cmake
RUN wget https://kojipkgs.fedoraproject.org/packages/libsolv/0.6.11/1.fc23/src/${PKG_NAME}\
 && rpm2cpio ${PKG_NAME} | cpio -idmv\
 && mkdir -p ~/rpmbuild/SOURCES/\
 && patch libsolv.spec libsolv-enable_complex_deps.patch\
 && cp *.tar.gz libsolv-rubyinclude.patch ~/rpmbuild/SOURCES/\
 && rm -f /usr/bin/python\
 && ln -s /usr/bin/python3 /usr/bin/python\
 && rpmbuild -bb libsolv.spec\
 && rm -f /usr/bin/python\
 && ln -s /usr/bin/python2 /usr/bin/python

VOLUME /repo 

RUN rpm -Uvh ~/rpmbuild/RPMS/x86_64/libsolv-0*\
 && echo -ne "[test]\nname=test\nbaseurl=file:///repo\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/test.repo

WORKDIR /
