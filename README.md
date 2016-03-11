
   Copyright 2015 ci-dnf-stack Authors. See the AUTHORS file
   found in the top-level directory of this distribution and
   at https://github.com/rpm-software-management/ci-dnf-stack/.

   Licensed under the GNU General Public License; either version 2,
   or (at your option) any later version. See the LICENSE file found
   in the top-level directory of this distribution and at
   https://github.com/rpm-software-management/ci-dnf-stack. No part
   of ci-dnf-stack, including this file, may be copied, modified,
   propagated, or distributed except according to the terms contained
   in the LICENSE file.


ci-dnf-stack
============

ci-dnf-stack is a set of scripts that allow continuous testing of the
DNF (https://github.com/rpm-software-management/dnf) stack.

This serves as an ad hoc solution to where to store routines that belong
to all the components of the stack. It would be nice to merge them into
the respective components.

These scripts are free and open-source software; see the section License
to understand the terms and conditions under which you can use, study,
modify and distribute ci-dnf-stack.

Dnf Docker Test in ci-dnf-stack
-------------------------------

The project originated from richdeps-docker (https://github.com/shaded-enmity/richdeps-docker).
Docker image for testing rich dependencies and CLI in DNF/RPM
using the Behave framework. The project was optimized for incorporation to
ci-dnf-stack as a module.
Each test runs in it's own container making it possible to run multiple tests
in parallel without interfering with each other. These tests are meant to
verify that both DNF and RPM (if relevant) interpret the rich dependency semantics
correctly and all functionality of DNF and related component is intact. Dnf Docker
Test use its own feature files and steps descriptions placed in its directory
(dnf-docker-test/).

Features
--------

Refer to the test suite for the complete list of all the features. I
have, nevertheless, mentioned few of them below in hope of gaining your
attention:

- create Copr projects
- add repositories to Copr projects
- build RPMs of tito-enabled projects
- build RPMs of librepo project forks
- build RPMs of libcomps project forks
- configure release numbers of librepo and libcomps RPMs


License
-------

The project is licensed under the copyleft GNU General Public License;
either version 2, or (at your option) any later version. See the
LICENSE file found in the top-level directory of this distribution and
at https://github.com/rpm-software-management/ci-dnf-stack/. No part of
ci-dnf-stack, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE
file.


Requirements
------------

ci-dnf-stack works on Python 2.7.

For local tests only docker is required and can be installed and set as follows:
```
$ sudo dnf install docker
$ sudo usermod -a -G dockerroot jenkins
```

Edit /etc/sysconfig/docker where replace line OPTIONS='--selinux-enabled' with OPTIONS='--selinux-enabled -G dockerroot'

Reboot server or logout and login jenkins user (ensure that jenkins user is able to see membership in dockerroot group)

Also additional setting could be required:
```
$ sudo systemctl start docker
$ sudo systemctl enable docker
```

Following executables and Python modules are required to run
ci-dnf-stack for Copr tests:

- `cp executable <http://www.gnu.org/software/coreutils/>`_
- `dirname executable <http://www.gnu.org/software/coreutils/>`_
- `echo executable <http://www.gnu.org/software/coreutils/>`_
- `git executable <http://git-scm.com/>`_
- `mv executable <http://www.gnu.org/software/coreutils/>`_
- `python executable <http://www.python.org/>`_
- `rm executable <http://www.gnu.org/software/coreutils/>`_
- `rpmbuild executable <http://www.rpm.org/>`_
- `sed executable <http://sed.sourceforge.net/>`_
- sh executable
- `tito executable <http://rm-rf.ca/tito>`_
- `xz executable <http://tukaani.org/xz/>`_
- `copr Python module <https://fedorahosted.org/copr/>`_
- `rpm Python module <http://www.rpm.org/>`_

Following additional executables and Python modules are required to run
a test suite:

- `behave Python module <http://github.com/behave/behave/>`_
- `pygit2 Python module <http://www.pygit2.org/>`_

To rebuild test-1 or upgrade_1 repository for Dnf Docker Test run test-1.py
or upgrade_1.py in dnf-docker-test/repo_create directory. It requires
following components:
python3-rpmfluff, createrepo, createrepo_c that can be installed as follows:
```
$ sudo dnf install python3-rpmfluff createrepo createrepo_c
```


Installation
------------

Install the requirements mentioned above and copy the distribution into
any directory you like.


Execute
-------

```
python2 ../ci-dnf-stack/cidnfstack.py build -c dnf-pull-requests tito
```
Localtest (omly for project that use tito):
```
python2 /path/to/cidnfstack.py build
```
Will test the project in current directory.

Or:
```
python2 /path/to/cidnfstack.py build -l /path/to/project/1/ -l /path/to/project/2/
```
Will test projects from directories described by -l option. To the environment
(docker container) it will install dnf eco-system nightly projects from COPR
rpmsoftwaremanagement/dnf-nightly, then it will install all requirements for
first project and install the project itself. The same process will be repeated
for second project and so on.


Binaries
--------

launch-test
Executes the test case specified in first parameter with Behave with dnf-2 or
dnf-3 that is specified in second
parameter.

Describing a test
-----------------

Here's an example configuration from the first ported test:

```
Feature: Richdeps/Behave test-1
 TestA requires (TestB or TestC), TestA recommends TestC

Scenario: Install TestA from repository "test-1"
 Given I use the repository "test-1"
 When I execute "dnf" command "install -y TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestC  |
   | absent       | TestB         |

```

Possible actions in step like  When I execute "dnf" command "install -y TestA" with "success":
    for "bash" commands: unlimited commands
    for "dnf" commands: the command without dnf is run with dnf-2 and dnf-3

Possible states: installed, removed, absent, upgraded, downgraded, present. The states present and absent can be used
for detailed description of tested step or to ensure, that required conditions before or after tested step were met.

Support
-------

If you are having issues, please report them via the issue tracking
system.

- issue tracker: https://github.com/rpm-software-management/ci-dnf-stack/issues


Notes for functional testing
----------------------------

Repo test-1-gpg:
Was created from rpms in test-1 repo. All rpm were signed with gpg-pubkey-2d2e7ca3-56c1e69d	gpg(DNF Test1 (TESTER)
<dnf@testteam.org>) except TestE (not signed), TestG (signed with key gpg-pubkey-705f3e8c-56c2e298	gpg(DNF Test2
(TESTER) <dnf@testteam.org>)), and TestJ (not signed and incorrect check-sum).

Repo upgrade_1-gpg:
Was created from rpms in upgrade_1 repo. All rpm were signed with gpg-pubkey-705f3e8c-56c2e298	gpg(DNF Test2
(TESTER) <dnf@testteam.org>) except both TestE (not signed) packages.


Contributions
-------------

Any contribution or feedback is more than welcome.

- version control system: https://github.com/rpm-software-management/ci-dnf-stack
