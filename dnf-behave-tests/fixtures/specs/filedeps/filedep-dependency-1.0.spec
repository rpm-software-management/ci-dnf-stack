Name:           filedep-dependency
Version:        1.0
Release:        1%{?dist}
Summary:        A dummy package providing a file.

License:        GPLv2+ and Public Domain
URL:            https://url.com/

BuildArch:      noarch

%description

%install
mkdir -p %{buildroot}/dummy
touch %{buildroot}/dummy/file

%files
/dummy/file

%changelog