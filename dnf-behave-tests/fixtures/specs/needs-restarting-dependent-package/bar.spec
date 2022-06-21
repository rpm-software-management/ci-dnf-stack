Name: bar
Version: 1.0
Release: 1%{?dist}
Summary: A package that provides a file used by foo

License: GPLv3+
Url: None

%description
Test package for needs-restarting plugins

%install
mkdir -p %{buildroot}/needs-restarting-utils
cat > %{buildroot}/needs-restarting-utils/%{name}-version.txt <<EOF
bar version 1.0
EOF

%files
/needs-restarting-utils/%{name}-version.txt

%changelog

