Name: foo
Version: 1.0
Release: 1%{?dist}
Summary: A package that triggers needs-restarting and uses a file provided by bar

License: GPLv3+
Url: None

BuildRequires: pkgconfig(bar)

%description
Test package for needs-restarting plugins

%install
mkdir -p %{buildroot}/needs-restarting-utils/
cat >> %{buildroot}/needs-restarting-utils/open-file.py <<EOF
from time import sleep
import os
with open(
    os.path.join(os.path.abspath(os.path.dirname(__file__)),
    "bar-version.txt"), "r") as f:
    while True:
        sleep(1)
EOF

cat >> %{buildroot}/needs-restarting-utils/run-forever.py <<EOF
import subprocess
import os
process = subprocess.Popen([
    '/usr/bin/python3',
    os.path.join(os.path.abspath(os.path.dirname(__file__)), 'open-file.py')
])
EOF

mkdir -p %{buildroot}/etc/dnf/plugins/needs-restarting.d/
echo "foo" > %{buildroot}/etc/dnf/plugins/needs-restarting.d/foo.conf

%files
/needs-restarting-utils/run-forever.py
/needs-restarting-utils/open-file.py
%dir /etc/dnf/plugins/needs-restarting.d
/etc/dnf/plugins/needs-restarting.d/foo.conf

%changelog
