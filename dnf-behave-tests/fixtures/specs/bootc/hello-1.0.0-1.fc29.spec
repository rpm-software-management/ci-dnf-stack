Name: hello
Version: 1.0
Release: 1.fc29
Summary: Made up package

License: GPLv3+
Url: None

Conflicts: hello
Provides: hello

%description
Description of a pkg that provides a file in /usr/bin and /etc

%install
mkdir -p %{buildroot}/usr/bin
touch %{buildroot}/usr/bin/hello
mkdir -p %{buildroot}/etc
touch %{buildroot}/etc/hello.conf

%files
/usr/bin/hello
/etc/hello.conf

%changelog
