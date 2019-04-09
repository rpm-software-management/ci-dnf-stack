%undefine _debuginfo_subpackages

Name:           postgresql
Epoch:          0
Version:        10.6
Release:        1.module_2594+0c9aadc5

License:        PostgreSQL
URL:            http://www.postgresql.org/

Summary:        PostgreSQL client programs

Provides:       postgresql(x86-64) = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       libpq.so.5()(64bit)
Requires:       postgresql-libs(x86-64) = 10.6-1.module_2594+0c9aadc5

%description
PostgreSQL is an advanced Object-Relational database management system (DBMS).
The base postgresql package contains the client programs that you'll need to
access a PostgreSQL DBMS server, as well as HTML documentation for the whole
system.  These client programs can be located on the same machine as the
PostgreSQL server, or on a remote machine that accesses a PostgreSQL server
over a network connection.  The PostgreSQL server can be found in the
postgresql-server sub-package.

%package contrib
Summary:        Extension modules distributed with PostgreSQL

Provides:       postgresql-contrib = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-contrib(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       libpq.so.5()(64bit)
Requires:       postgresql-libs(x86-64) = 10.6-1.module_2594+0c9aadc5
Requires:       postgresql(x86-64) = 10.6-1.module_2594+0c9aadc5

%description contrib
The postgresql-contrib package contains various extension modules that are
included in the PostgreSQL distribution.

%package devel
Summary:        PostgreSQL development header files and libraries

Provides:       postgresql-devel(x86-64) = 10.6-1.module_2594+0c9aadc5
Provides:       pkgconfig(libecpg) = 10.6
Provides:       pkgconfig(libecpg_compat) = 10.6
Provides:       pkgconfig(libpgtypes) = 10.6
Provides:       pkgconfig(libpq) = 10.6
Provides:       postgresql-devel = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       libpq.so.5()(64bit)
Requires:       libpgtypes.so.3()(64bit)
Requires:       pkgconfig(libpgtypes)
Requires:       pkgconfig(libpq)
Requires:       postgresql-libs(x86-64) = 10.6-1.module_2594+0c9aadc5

%description devel
Package contains the header files and configuration needed to compile PostgreSQL
server extension.

%package docs
Summary:        Extra documentation for PostgreSQL

Provides:       postgresql-doc = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-docs = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-docs(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       postgresql(x86-64) = 10.6-1.module_2594+0c9aadc5

%description docs
The postgresql-docs package contains some additional documentation for
PostgreSQL.  Currently, this includes the main documentation in PDF format
and source files for the PostgreSQL tutorial.

%package libs
Summary:        The shared libraries required for any PostgreSQL clients

Provides:       libpq.so.5()(64bit)
Provides:       libecpg.so.6()(64bit)
Provides:       libecpg_compat.so.3()(64bit)
Provides:       libpgtypes.so.3()(64bit)
Provides:       postgresql-libs(x86-64) = 10.6-1.module_2594+0c9aadc5
Provides:       libpq.so = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-libs = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)

%description libs
The postgresql-libs package provides the essential shared libraries for any
PostgreSQL client program or interface. You will need to install this package
to use any other PostgreSQL package or any clients that need to connect to a
PostgreSQL server.

%package plperl
Summary:        The Perl procedural language for PostgreSQL

Provides:       postgresql-plperl = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-plperl(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       postgresql-server(x86-64) = 10.6-1.module_2594+0c9aadc5

%description plperl
The postgresql-plperl package contains the PL/Perl procedural language,
which is an extension to the PostgreSQL database server.
Install this if you want to write database functions in Perl.

%package plpython
Summary:        The Python2 procedural language for PostgreSQL

Provides:       postgresql-plpython = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-plpython(x86-64) = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-plpython2 = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       postgresql-server(x86-64) = 10.6-1.module_2594+0c9aadc5

%description plpython
The postgresql-plpython package contains the PL/Python procedural language,
which is an extension to the PostgreSQL database server.
Install this if you want to write database functions in Python 2.

%package plpython3
Summary:        The Python3 procedural language for PostgreSQL

Provides:       postgresql-plpython3 = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-plpython3(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       postgresql-server(x86-64) = 10.6-1.module_2594+0c9aadc5

%description plpython3
The postgresql-plpython3 package contains the PL/Python3 procedural language,
which is an extension to the PostgreSQL database server.
Install this if you want to write database functions in Python 3.

%package pltcl
Summary:        The Tcl procedural language for PostgreSQL

Provides:       postgresql-pltcl = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-pltcl(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       postgresql-server(x86-64) = 10.6-1.module_2594+0c9aadc5

%description pltcl
The postgresql-pltcl package contains the PL/Tcl procedural language,
which is an extension to the PostgreSQL database server.
Install this if you want to write database functions in Tcl.

%package server
Summary:        The programs needed to create and run a PostgreSQL server

Provides:       postgresql-server(:MODULE_COMPAT_10)
Provides:       postgresql-server(x86-64) = 10.6-1.module_2594+0c9aadc5
Provides:       bundled(postgresql-setup) = 8.2
Provides:       postgresql-server = 10.6-1.module_2594+0c9aadc5
Provides:       config(postgresql-server) = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       libpq.so.5()(64bit)
Requires:       postgresql-libs(x86-64) = 10.6-1.module_2594+0c9aadc5
Requires:       postgresql(x86-64) = 10.6-1.module_2594+0c9aadc5

%description server
PostgreSQL is an advanced Object-Relational database management system (DBMS).
The postgresql-server package contains the programs needed to create
and run a PostgreSQL server, which will in turn allow you to create
and maintain PostgreSQL databases.

%package static
Summary:        Statically linked PostgreSQL libraries

Provides:       postgresql-static = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-static(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       postgresql-devel(x86-64) = 10.6-1.module_2594+0c9aadc5

%description static
Statically linked PostgreSQL libraries that do not have dynamically linked
counterparts.

%package test
Summary:        The test suite distributed with PostgreSQL

Provides:       postgresql-test = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-test(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       postgresql-server(x86-64) = 10.6-1.module_2594+0c9aadc5
Requires:       postgresql-devel(x86-64) = 10.6-1.module_2594+0c9aadc5

%description test
The postgresql-test package contains files needed for various tests for the
PostgreSQL database management system, including regression tests and
benchmarks.

%package test-rpm-macros
Summary:        Convenience RPM macros for build-time testing against PostgreSQL server

Provides:       postgresql-test-rpm-macros = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-test-rpm-macros(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       postgresql-server = 10.6-1.module_2594+0c9aadc5

%description test-rpm-macros
This package is meant to be added as BuildRequires: dependency of other packages
that want to run build-time testsuite against running PostgreSQL server.

%package upgrade
Summary:        Support for upgrading from the previous major release of PostgreSQL

Provides:       postgresql-upgrade(x86-64) = 10.6-1.module_2594+0c9aadc5
Provides:       bundled(postgresql-server) = 9.6.11
Provides:       postgresql-upgrade = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       libpq.so.5()(64bit)
Requires:       postgresql-server(x86-64) = 10.6-1.module_2594+0c9aadc5
Requires:       postgresql-libs(x86-64) = 10.6-1.module_2594+0c9aadc5

%description upgrade
The postgresql-upgrade package contains the pg_upgrade utility and supporting
files needed for upgrading a PostgreSQL database from the previous major
version of PostgreSQL.

%package upgrade-devel
Summary:        Support for build of extensions required for upgrade process

Provides:       postgresql-upgrade-devel = 10.6-1.module_2594+0c9aadc5
Provides:       postgresql-upgrade-devel(x86-64) = 10.6-1.module_2594+0c9aadc5

Requires:       rtld(GNU_HASH)
Requires:       postgresql-upgrade(x86-64) = 10.6-1.module_2594+0c9aadc5

%description upgrade-devel
The postgresql-devel package contains the header files and libraries
needed to compile C or C++ applications which are necessary in upgrade
process.

%files

%files contrib

%files devel

%files docs

%files libs

%files plperl

%files plpython

%files plpython3

%files pltcl

%files server

%files static

%files test

%files test-rpm-macros

%files upgrade

%files upgrade-devel

%changelog
