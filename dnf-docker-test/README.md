# richdeps-docker
Docker image for testing rich dependencies in DNF/RPM using the Behave framework

## Overview
Each test runs in it's own container making it possible to run multiple tests
in parallel without interfering with each other. These tests are meant to
verify that both DNF and RPM (if relevant) interpret the rich dependency semantics
correctly. In overall the system is written in such a way that it is package-manager
agnostic, so plugging in tests for `PackageKit` is just about providing correct
CLI arguments.

## Usage

Install:
```
$ git clone https://github.com/shaded-enmity/richdeps-docker/
$ cd richdeps-docker/
$ docker pull pavelo/richdeps:1.0.2
```

Execute test:
```
$ ./test-launcher.py test-1
```

To rebuild the Docker image you can use the following command:
```
$ cd richdeps-docker/
$ docker build -t pavelo/richdeps:1.0.2 .
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

Possible actions: install, remove

Possible package managers: dnf, rpm (pkcon soonish)

Possible states: installed, removed, absent
