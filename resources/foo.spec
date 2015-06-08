%global datadn /usr/share/foo

Name: foo
Version: 1
Release: 1
Summary: a testing package
License: GPLv2+
Source: %{name}-%{version}.tar.gz
BuildRequires: /etc/os-release
BuildRequires: /usr/bin/mkdir
BuildRequires: /usr/bin/touch

%description
A package intended to test DNF.

%install
source /etc/os-release
mkdir --parents "%{buildroot}/%{datadn}"
touch "%{buildroot}/%{datadn}/$ID" "%{buildroot}/%{datadn}/$VERSION_ID"

%files
%{datadn}/
