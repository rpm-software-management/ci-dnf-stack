Name: configurable
Version: 1.0
Release: 1.fc29
Summary: A package with config file

License: GPLv3+
Url: None

%description
Description of a pkg that provides a file in /usr/bin and /etc

%install
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/etc/configurable-1
mkdir -p %{buildroot}/etc/configurable-2
mkdir -p %{buildroot}/etc/configurable-3
mkdir -p %{buildroot}/var/lib/configurable
touch %{buildroot}/usr/bin/configurable
touch %{buildroot}/etc/configurable-1/configurable.conf
touch %{buildroot}/etc/configurable-2/configurable.conf
touch %{buildroot}/etc/configurable-3/configurable.conf
# Include a path that is not usually listed in primary.xml
touch %{buildroot}/var/lib/configurable/configurable.db

%files
/usr/bin/configurable
/etc/configurable-1/configurable.conf
/etc/configurable-2/configurable.conf
/etc/configurable-3/configurable.conf
/var/lib/configurable/configurable.db

%changelog
