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
BuildRequires:  python3
BuildRequires:  python3-distro
BuildRequires:  python3-pip
# a missing dep of python3-pip on f35 beta, remove when unneeded
BuildRequires:  python3-setuptools
BuildRequires:  rpm-build
BuildRequires:  rpm-sign
BuildRequires:  sqlite
BuildRequires:  yq
BuildRequires:  zstd
%if 0%{?fedora}
%if 0%{?fedora} < 44
BuildRequires:  python3-behave < 1.2.7
%endif
BuildRequires:  python3-pexpect
BuildRequires:  zchunk
%endif

# tested packages
BuildRequires:  createrepo_c

# For newer fedoras we don't build dnf-automatic and dnf/yum packages because of dnf5
# https://github.com/rpm-software-management/dnf/commit/f519e602a70ce6d3494a9d9d70464187eb9c263e
# https://github.com/rpm-software-management/dnf/commit/d50a6b2a63976bd3e4a0cf99b53aa9cfc189f68a
%if 0%{?fedora} < 41
BuildRequires:  dnf
BuildRequires:  dnf-automatic
BuildRequires:  yum
%else
BuildRequires:  python3-dnf
%endif

BuildRequires:  dnf-plugins-core
BuildRequires:  dnf-utils
BuildRequires:  python3-dnf-plugin-modulesync
BuildRequires:  python3-dnf-plugin-post-transaction-actions
BuildRequires:  python3-dnf-plugin-pre-transaction-actions
BuildRequires:  python3-dnf-plugin-versionlock
BuildRequires:  python3-dnf-plugins-core
BuildRequires:  python3-dnf-plugin-leaves
BuildRequires:  python3-dnf-plugin-show-leaves

%if 0%{?fedora}
BuildRequires:  python3-dnf-plugin-system-upgrade
%if 0%{?fedora} < 39
BuildRequires:  dnf-plugin-swidtags
%endif
%endif

BuildRequires:  microdnf

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
