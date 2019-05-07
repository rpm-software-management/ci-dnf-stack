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
(dnf-docker-test/).

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
* jq

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
`test-1.py` or `upgrade_1.py` in `dnf-docker-test/repo_create directory`.
It requires following components:
* python3-rpmfluff

Configuring Jenkins
-------------------

We are using [jenkins-job-builder](http://docs.openstack.org/infra/jenkins-job-builder/)
to manage jenkins jobs.

To deploy jobs you need configure your [jenkins_jobs.ini](http://docs.openstack.org/infra/jenkins-job-builder/execution.html)
and run `jenkins-jobs --config=/path/to/jenkins_jobs.ini update jobs/`.

Local run
---------

Local test can be performed with dnf-testing.sh
* Container build:
  * Put your RPMs into ``rpms`` directory
  * Then run ``dnf-testing.sh build``
* Run tests:
  * Run all tests with last built container: ``./dnf-testing.sh run``
  * Run all tests with specified container: ``./dnf-testing.sh run -c <CONTAINER>``
  * Run particular tests: ``./dnf-testing.sh run TEST-A.feature TEST-B.feature ...``
* Run in devel mode:
  * It shares local feature dir with description of tests and test steps with docker image, therefore you can develop CI stack on the fly.
  * Use command ``./dnf-testing.sh run --devel $CONTAINER TEST-A``
* Get help:
  * ``./dnf-testing.sh --help``


Describing a test
-----------------

Here's an example configuration from the first ported test:

```
Feature: Install package with dependency

    @setup
    Scenario: Feature setup
        Given repository "test" with packages
           | Package | Tag      | Value |
           | TestA   | Requires | TestB |
           | TestB   |          |       |

    Scenario: Install TestA from repository "test" with dependency TestB
         When I save rpmdb
          And I enable repository "test"
          And I successfully run "dnf install -y TestA" with "success"
         Then rpmdb changes are
           | State     | Packages     |
           | installed | TestA, TestB |
```

Possible states: installed, removed, absent, unchanged, reinstalled, updated, downgraded.
The states unchanged and absent can be used
for detailed description of tested step or to ensure, that required conditions before or after tested step were met.

Support
-------

If you are having issues, please report them via the issue tracking
system.

- issue tracker: https://github.com/rpm-software-management/ci-dnf-stack/issues

Notes for functional testing
----------------------------

Repo upgrade_1:
updateinfo.xml was added using modifyrepo_c updateinfo.xml path/upgrade_1/repodata/

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
