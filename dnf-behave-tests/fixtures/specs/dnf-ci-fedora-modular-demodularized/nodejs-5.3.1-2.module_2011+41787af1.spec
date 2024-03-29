%undefine _debuginfo_subpackages

Name:           nodejs
Epoch:          1
Version:        5.3.1
Release:        2.module_2011+41787af1

License:        MIT and ASL 2.0 and ISC and BSD
URL:            http://nodejs.org/

Summary:        JavaScript runtime

Provides:       nodejs = 1:5.3.1-2.module_2011+41787af1
Provides:       nodejs(x86-64) = 1:5.3.1-2.module_2011+41787af1
Provides:       bundled(c-ares) = 1.10.1
Provides:       bundled(icu) = 60.1
Provides:       bundled(v8) = 6.2.414.54
Provides:       nodejs(abi) = 5.3
Provides:       nodejs(abi8) = 5.3
Provides:       nodejs(engine) = 5.3.1
Provides:       nodejs(v8-abi) = 6.2
Provides:       nodejs(v8-abi6) = 6.2
Provides:       nodejs-punycode = 2.0.0
Provides:       npm(punycode) = 2.0.0

Requires:       rtld(GNU_HASH)

Conflicts:      node <= 0.3.2-12

Recommends:     npm

%description
Node.js is a platform built on Chrome's JavaScript runtime
for easily building fast, scalable network applications.
Node.js uses an event-driven, non-blocking I/O model that
makes it lightweight and efficient, perfect for data-intensive
real-time applications that run across distributed devices.

%package devel
Summary:        JavaScript runtime - development headers

Provides:       nodejs-devel = 1:5.3.1-2.module_2011+41787af1
Provides:       nodejs-devel(x86-64) = 1:5.3.1-2.module_2011+41787af1

Requires:       rtld(GNU_HASH)
Requires:       nodejs(x86-64) = 1:5.3.1-2.module_2011+41787af1

%description devel
Development headers for the Node.js JavaScript runtime.

%package docs
Summary:        Node.js API documentation
BuildArch:      noarch

Provides:       nodejs-docs = 1:5.3.1-2.module_2011+41787af1

Conflicts:      nodejs < 1:5.3.1-2.module_2011+41787af1
Conflicts:      nodejs > 1:5.3.1-2.module_2011+41787af1

%description docs
The API documentation for the Node.js JavaScript runtime.

%changelog
