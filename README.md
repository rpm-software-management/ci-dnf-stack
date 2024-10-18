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


rpm-gitoverlay Overlays
-----------------------

The [rpm-gitoverlay](https://github.com/rpm-software-management/rpm-gitoverlay)
tool is used to build the DNF stack RPMs in Copr. You can find rpm-gitoverlay
RPM packages in [its own Copr repository](https://copr.fedorainfracloud.org/coprs/rpmsoftwaremanagement/rpm-gitoverlay/).
Use `dnf copr enable rpmsoftwaremanagement/rpm-gitoverlay` to add the
repository on your system.

The configurations for groups of packages to build can be found in the
[`overlays`](overlays) directory.  As an example, assuming you have your [Copr
API token configured](https://copr.fedorainfracloud.org/api/), you can build
the `dnf-ci` overlay (the stack of packages that is tested by the `dnf` test
suite) with this command:
```
rpm-gitoverlay -o rpmlist --gitdir=gits build-overlay -s overlays/dnf-ci rpm copr --owner YOUR_COPR_USERNAME --project my-test-build --chroot fedora-33-x86_64 --delete-project-after-days=2
```

Where:
- `-o rpmlist` will output the full list of built RPMs into the `rpmlist` file
- `--gitdir=gits` specifies the directory to which rpm-gitoverlay will clone
  the components' git repositories
- `-s overlays/dnf-ci` specifies the path to the overlay to build
- `--delete-project-after-days=2` will tell Copr to delete the project in two
  days, meaning you don't have to clean up manually later

You can then download the built RPMs into the `rpms/` directory:
```
for RPM in $(cat rpmlist); do wget -P rpms $RPM; done
```

And you're set to run the test suite on the RPMs.

In case you want to build some components of the stack with your changes,
simply set up your clone in `gits/COMPONENT` and run the above command. If
`rpm-gitoverlay` finds an existing git repository for a component in the
`--gitdir`, it will use it as-is.


CI in Github Actions
--------------------

The DNF stack CI is implemented in Github Actions. The code that makes up the
CI is located in [`.github/workflows/`](.github/workflows/) in this repository
as well as in all the stack component repositories. The CI workflow files are
mostly the same across the repositories, and some of the code is shared between
them in form of actions, located in [`.github/actions/`](.github/actions/).

The bootstrap of the CI (on a Pull Request) in Github Actions for a repository
in the stack is done in a bit unconventional way:

1. The first git repository that is cloned is this, `ci-dnf-stack`. This then
makes the shared actions available to be called.

2. Then, the Pull Request target repository is cloned into `gits/REPO` (the PR
HEAD is checked out and subsequently rebased on the target branch to bring it
up to date). This is then used directly by `rpm-gitoverlay`,
[see above](#rpm-gitoverlay-overlays).

### Workflow Host Image

All DNF stack CI workflows run on a base Fedora container image. Since we need
some additional tools installed, to save on installing these on a vanilla
Fedora image on every CI run, we create a daily host image and store it in
Github Container Registry. This is done in `.github/workflows/ci-host.yml`.

### Setting Up the Workflows on a Fork

For the Github Actions workflows to work on a fork, you need two secrets
configured on your Github repository:
- `COPR_USER`: Your Copr username; Since Github Actions automatically scrub any
  secret value from the workflow outputs (e.g. in Copr URLs in the log), there
  is a workaround to avoid this on the username: append a `#` (bash comment
  sign) to the end of the secret. It is dropped in a bash variable assignment
  in the workflow and the username is no longer masked in the output.
- `COPR_API_TOKEN`: The full contents of [Copr API
  token](https://copr.fedorainfracloud.org/api/) meant to go into
  `~/.config/copr`.


Nightly Builds
--------------

The DNF stack nightlies are built via a Github Actions workflow:
`.github/workflows/nightly.yml`.

The built nightlies can be found in the [rpmsoftwaremanagement
Copr](https://copr.fedorainfracloud.org/coprs/rpmsoftwaremanagement/dnf-nightly/).


Integration Tests of Users of the DNF Stack
-------------------------------------------

The aim is to run integration tests of projects that depend on the DNF stack,
so that regressions can be caught early and close to the source.

So far there's only the Ansible integration test suite (specifically its part
that concerns DNF) integrated into our CI.
