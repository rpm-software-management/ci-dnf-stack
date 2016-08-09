ci-dnf-stack
============

ci-dnf-stack is a set of configuration and scripts that allow continuous
integrations DNF (https://github.com/rpm-software-management/dnf) stack.

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
(features/).

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

* python
* python3 >= 3.5
* jenkins
* docker
* git-core
* /usr/bin/rpmbuild
* docker

For building in COPR:
* python3-copr
* python3-beautifulsoup4
* python3-requests

sudo should be configured for `jenkins` user to use `docker`:
```
# cat << EOF > /etc/sudoers.d/99-jenkins
jenkins ALL=(ALL) NOPASSWD: /usr/bin/docker
EOF
```

To rebuild `test-1` or `upgrade_1` repository for Dnf Docker Test run
`test-1.py` or `upgrade_1.py` in `repo_create` directory.
It requires following components:
* python3-rpmfluff
* createrepo
* createrepo_c

Configuring Jenkins
-------------------

We are using [jenkins-job-builder](http://docs.openstack.org/infra/jenkins-job-builder/)
to manage jenkins jobs.

To deploy jobs you need configure your [jenkins_jobs.ini](http://docs.openstack.org/infra/jenkins-job-builder/execution.html)
and run `jenkins-jobs --config=/path/to/jenkins_jobs.ini update jobs/`.

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
