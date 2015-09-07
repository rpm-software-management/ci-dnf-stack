FROM fedora:rawhide
MAINTAINER Pavel Odvody <podvody@redhat.com>

RUN dnf -y install automake cmake dnf-plugins-core expat-devel \
                   gcc-c++ git make python-behave rpm-build wget which\
 && dnf -y builddep rpm libsolv

RUN git clone https://github.com/rpm-software-management/rpm.git\
 && (cd rpm/\
  && ./autogen.sh --prefix=/usr --with-external-db --enable-python CPPFLAGS="-I/usr/include/nspr4 -I/usr/include/nss3"\
  && make && make install)

RUN git clone https://github.com/openSUSE/libsolv.git\
 && (cd libsolv/ && mkdir build && cd build/\ 
  && cmake -DENABLE_COMPLEX_DEPS=1 -DUSE_VENDORDIRS=1 -DFEDORA=1 -DCMAKE_INSTALL_PREFIX=/usr ../\
  && make && make install)

ADD launch-test /usr/bin/
VOLUME /repo 

RUN echo -ne "[test]\nname=test\nbaseurl=file:///repo\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/test.repo

ENTRYPOINT ["launch-test"]
