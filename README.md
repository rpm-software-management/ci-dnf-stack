ci-dnf-stack
============

This repository contains the integration test suite (a.k.a. the behave tests)
of the DNF stack, along with tooling to run the suite in containers (which are
used for sandboxing, some of the DNF tests are destructive to the system), and
the shared CI setup for DNF stack components.

For documentation of the integration test suite based on behave, see
[`dnf-behave-tests/README.md`](dnf-behave-tests/README.md).


Running the Containerized Test Suite
------------------------------------

To set up clean and sandboxed environment, the integration test suite is run in
containers. The dockerfiles in the root directory are used to build the image
in which the tests are run.

For destructive tests, each destructive scenario is run in its own container.
For non-destructive tests one container per feature file is run.

### Building the Container Image to Run Tests

Build the container image for the tests:
```
./container-test build
```

You can also quite simply run the tests on a different distribution than the
default:
```
./container-test build --base quay.io/centos/centos:stream8
```

If any additional repositories are needed to be added to the container image,
you can place them into the `repos.d` directory (mainly useful for RHEL).

If any additional CA certificates are needed to be trusted in the container
image, e.g. for the additional repositories, you can place them into the
`ca-trust` directory.

During the build, any RPMs found in the `rpms` directory are installed in the
image. Place your RPMs to be tested in this directory.

Barring these, the latest versions of the DNF stack RPMs from the dnf-nightly
Copr repository (see [Nightly Builds](#Nightly-Builds) below) are installed on
the system, unless you disable this via the `--type` argument (the value of
this argument should be whatever the `Dockerfile` supports, in this case
anything other than `"nightly"` will do the job):
```
./container-test build --type distro
```

The full integration test suite directory (`dnf-behave-tests`) is copied into
the image during the build.

### Running the Tests

Run the integration test suite in containers:
```
./container-test run
```

The integration test suite actually contains two distinct test suites, `dnf`
(default) and `createrepo_c`. To specify the suite, use the `-s` switch:
```
./container-test -s createrepo_c run
```

For development, it is possible to dynamically mount the features directory of
the given suite by using the `-d` switch:
```
./container-test -s createrepo_c -d run
```

To only run a subset of a suite, simply specify the feature files (this will
run scenarios in `dnf-behave-tests/dnf/config.feature`, as `dnf` is the
default test suite):
```
./container-test run config.feature
```

For documentation of the rest of the options of the script, use `--help`:
```
./container-test --help
./container-test COMMAND --help
```


Nightly Builds
--------------

The DNF stack nightlies are built via a Github Actions workflow
`.github/workflows/nightly.yml` in the `main` branch.

The built nightlies can be found in the [rpmsoftwaremanagement
Copr](https://copr.fedorainfracloud.org/coprs/rpmsoftwaremanagement/dnf-nightly/).


Integration Tests of Users of the DNF Stack
-------------------------------------------

The aim is to run integration tests of projects that depend on the DNF stack,
so that regressions can be caught early and close to the source.

