# dnf_docker_test in ci-dnf-stack
The project originated from richdeps-docker (https://github.com/shaded-enmity
/richdeps-docker). Docker image for testing rich dependencies and CLI in DNF/RPM
using the Behave framework. The project was optimized for incorporation to
ci-dnf-stack as a module.

## Overview
Each test runs in it's own container making it possible to run multiple tests
in parallel without interfering with each other. These tests are meant to
verify that both DNF and RPM (if relevant) interpret the rich dependency semantics
correctly. In overall the system is written in such a way that it is package-manager
agnostic, so plugging in tests for `PackageKit` is just about providing correct
CLI arguments.

## Execute

Tests can be executed using --dnf_docker_test option for ci-dnf-stack

Example:
```
python2 ../ci-dnf-stack/cidnfstack.py --dnf_docker_test build dnf-pull-requests tito)
```

## Requirements for Jenkins

$ sudo dnf install docker python3-rpmfluff
$ sudo usermod -a -G dockerroot jenkins

Edit /etc/sysconfig/docker where replace line OPTIONS='--selinux-enabled' with OPTIONS='--selinux-enabled -G dockerroot'

Reboot server or logout and login jenkins user (ensure that jenkins user is able to see membership in dockerroot group)

## Notes

To rebuild the Docker image you can use the following command:
```
$ cd dnf_docker_test/
$ sudo docker build -t jmracek/dnftest:1.0.2 .
```

## Binaries

### test-launcher.py
Launches the `test-suite` container (mounting, result collection ...).

### launch-test
Executes the test case specified in first parameter with Behave.

## Describing a test

Here's an example configuration from the first ported test:

```
Feature: Richdeps/Behave test-1
 TestA requires (TestB or TestC), TestA recommends TestC

Scenario: Install TestA from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestC" should be "installed"
 And package "TestB" should be "absent"

```

Possible actions:
    for rpm: install, remove
    for dnf: install, remove, upgrade, upgrade (with package name: all), upbrade-to,
    downgrade, autoremove
    for command-line commands: unlimited

Possible package managers: dnf, rpm

Possible states: installed, removed, absent, upgraded, unupgraded, downgraded, present,
upgraded-to
