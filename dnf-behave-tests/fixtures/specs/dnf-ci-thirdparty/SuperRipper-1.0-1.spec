Name:           SuperRipper
Epoch:          0
Version:        1.0
Release:        1

License:        Public Domain
URL:            None

Summary:        The made up package for autoremove testing.

BuildRequires:  %{?buildrequires}%{?!buildrequires:lame-libs}
Requires:       abcde

%description
This package in 1.0 version requires abcde. In 1.2 version is this dependency dropped.
It is used for testing autoremove command.

%files

%changelog
