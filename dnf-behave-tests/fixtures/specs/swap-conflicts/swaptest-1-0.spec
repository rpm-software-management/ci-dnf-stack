Summary: swaptest Package
Name: swaptest
Version: 1
Release: 0
License: GPL
BuildArch: noarch
Requires: libswaptest%{_isa} >= %{version}-%{release}

%description
swaptest is a package that depends on one of two interchangeable dependency
sub-packages.

%package -n libswaptest
Summary: library dependency for swaptest
Provides: libswaptest = %{version}-%{release}
Provides: libswaptest%{?_isa} = %{version}-%{release}
Provides: libswaptest-full = %{version}-%{release}
Provides: libswaptest-full%{?_isa} = %{version}-%{release}

%description -n libswaptest
libswaptest is a fuller library for swaptest package

%package -n libswaptest-minimal
Summary: minimal dependency for swaptest
Provides: libswaptest = %{version}-%{release}
Provides: libswaptest%{?_isa} = %{version}-%{release}
Provides: libswaptest-minimal = %{version}-%{release}
Provides: libswaptest-minimal%{?_isa} = %{version}-%{release}
Conflicts: libswaptest%{?_isa}

%description -n libswaptest-minimal
libswaptest-minimal is minimalistic replacement for libswaptest library

%build

%install
mkdir -p %{buildroot}/%{_bindir}
touch %{buildroot}/%{_bindir}/swaptest
mkdir -p %{buildroot}/%{_libdir}
touch %{buildroot}/%{_libdir}/libswaptest
touch %{buildroot}/%{_libdir}/libswaptest-minimal
touch %{buildroot}/%{_libdir}/libswaptest-full

%files
%{_bindir}/swaptest

%files -n libswaptest
%{_libdir}/libswaptest
%{_libdir}/libswaptest-full

%files -n libswaptest-minimal
%{_libdir}/libswaptest
%{_libdir}/libswaptest-minimal

%changelog
* Thu Apr 23 2026 Jan Blazek <jblazek@redhat.com> - 1-0
- initial version
