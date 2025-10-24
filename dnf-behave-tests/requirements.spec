# This package is not meant to be built, it's for installing the test suite
# dependencies.
#
# Run the following command to install the dependencies:
# $ dnf builddep ci-dnf-stack.spec
#
# Some of the dependencies may not be available as RPMs on the target system.
# We use pip for those:
# $ pip3 install -r requirements.txt

Name:           dnf-integration-test-suite-requirements
Version:        1
Release:        1
Summary:        Requirements for the DNF Integration Test Suite.
License:        GPLv3


# test suite dependencies
BuildRequires:  attr
BuildRequires:  createrepo_c
BuildRequires:  fakeuname
BuildRequires:  findutils
BuildRequires:  glibc-langpack-en
BuildRequires:  glibc-langpack-de
BuildRequires:  libfaketime
BuildRequires:  openssl
BuildRequires:  python3 >= 3.11
BuildRequires:  python3-distro
BuildRequires:  python3-pip
BuildRequires:  python3-rpm
# a missing dep of python3-pip on f35 beta, remove when unneeded
BuildRequires:  python3-setuptools
BuildRequires:  rpm-build
BuildRequires:  rpm-sign
BuildRequires:  sqlite
BuildRequires:  yq
BuildRequires:  zstd
%if 0%{?fedora}
BuildRequires:  python3-behave
BuildRequires:  python3-pexpect
BuildRequires:  zchunk
%endif

# tested packages
BuildRequires:  createrepo_c

# dnfdaemon
BuildRequires:  dbus-daemon
BuildRequires:  python3-dbus
BuildRequires:  polkit

BuildRequires:  dnf5
BuildRequires:  dnf5-plugins
BuildRequires:  dnf5-plugin-automatic
BuildRequires:  dnf5-plugin-manifest
BuildRequires:  dnf5daemon-server
BuildRequires:  dnf5daemon-client
BuildRequires:  libdnf5-plugin-actions
BuildRequires:  libdnf5-plugin-local
BuildRequires:  libdnf5-plugin-expired-pgp-keys
# dnf5 python api tests need libdnf5 python bindings
BuildRequires:  python3-libdnf5

# debugging tools (always installed for simplicity)
BuildRequires: less
BuildRequires: openssh-clients
BuildRequires: procps-ng
BuildRequires: psmisc
BuildRequires: strace
BuildRequires: tcpdump
BuildRequires: vim-enhanced
BuildRequires: wget

%description
Requirements for the DNF Integration Test Suite.

%files

%changelog
