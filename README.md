# richdeps-docker
Docker image for testing rich dependencies in DNF/RPM

## Overview
Each test runs in it's own container making it possible to run multiple tests
in parallel without interfering with each other. These tests are meant to
verify that both DNF and RPM (if relevant) interpret the rich dependency semantics
correctly. In overall the system is written in such a way that it is package-manager
agnostic, so plugging in tests for `PackageKit` is just about providing correct
CLI arguments.

## Binaries

### test-launcher
Launches the `test-suite` container (mounting, result collection ...).

### test-suite
Executes each case in the `JSON` passed in by the `test-launcher`.

## Describing a test

```
{
  "name": "TestA installation using DNF",
  "description": "TestA `Requires: (TestB | TestC)` and `Recommends: TestC`",
  "repository": "repos/test-1",
  "cases": [
    { "pre_packages": [], "post_packages": ["+TestA", "+TestC"], 
      "command": ["install", "TestA"], "type": "dnf", "return_code": 0}
  ]
}
```

| Key | Value |
------|--------
| **name** | name of the test |
| **description** | description od the test |
| **repository** | path relative to `$(pwd)` which will be bind-mounted into the container (use `createrepo_c`) |
| **cases** | a list of test cases |


| Key | Value |
------|--------
| **pre_packages** | unused |
| **post_packages** | + = installed package / - = removed package |
| **return_code** | |
| **type** | `dnf/rpm` |
| **command** | what to pass to `dnf/rpm` along with default flags |


## Examples

As of now the test suite contains two tests that work against the same repository, yet one fails
and the other one succeeds. (hint: the second test installs TestB first, and the test fails because TestC is also installed)
