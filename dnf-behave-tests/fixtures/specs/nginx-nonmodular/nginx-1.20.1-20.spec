Name:           nginx
Epoch:          2
Version:        1.20.1
Release:        20.el9
Summary:        A high performance web server and reverse proxy server (non-modular)

License:        BSD
URL:            http://nginx.org/


%description
Nginx is a web server and a reverse proxy server for HTTP, SMTP, POP3 and
IMAP protocols, with a strong focus on high concurrency, performance and low
memory usage. This is the non-modular version with epoch 2.

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
