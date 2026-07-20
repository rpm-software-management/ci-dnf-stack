Name:           nginx
Epoch:          1
Version:        1.22.1
Release:        1.module_el9+5000+aa9aadc5
Summary:        A high performance web server and reverse proxy server (modular)

License:        BSD
URL:            http://nginx.org/


%description
Nginx is a web server and a reverse proxy server for HTTP, SMTP, POP3 and
IMAP protocols, with a strong focus on high concurrency, performance and low
memory usage. This is the modular version from stream 1.22.

%package filesystem
Summary:        The basic directory layout for the Nginx server
BuildArch:      noarch

%description filesystem
The nginx-filesystem package contains the basic directory layout
for the Nginx server including the correct permissions for the
directories.

%package core
Summary:        nginx minimal core

%description core
nginx minimal core

%prep

%build

%files

%files filesystem

%files core

%changelog
