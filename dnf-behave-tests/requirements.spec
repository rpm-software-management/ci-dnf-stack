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
BuildRequires:  libfaketime
BuildRequires:  openssl
BuildRequires:  python3
BuildRequires:  python3-distro
BuildRequires:  python3-pip
# a missing dep of python3-pip on f35 beta, remove when unneeded
BuildRequires:  python3-setuptools
BuildRequires:  rpm-build
BuildRequires:  rpm-sign
BuildRequires:  sqlite
%if 0%{?fedora}
BuildRequires:  python3-behave < 1.2.7
BuildRequires:  python3-pexpect
BuildRequires:  zchunk
%endif

# tested packages
BuildRequires:  createrepo_c

BuildRequires:  dnf
BuildRequires:  dnf-automatic
BuildRequires:  yum

BuildRequires:  dnf-plugins-core
BuildRequires:  dnf-utils
BuildRequires:  python3-dnf-plugin-post-transaction-actions
BuildRequires:  python3-dnf-plugin-versionlock
BuildRequires:  python3-dnf-plugins-core

%if 0%{?fedora}
BuildRequires:  python3-dnf-plugin-system-upgrade
BuildRequires:  dnf-plugin-swidtags
%endif

BuildRequires:  microdnf

# dnfdaemon
BuildRequires:  dbus-daemon
BuildRequires:  python3-dbus
BuildRequires:  polkit

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
