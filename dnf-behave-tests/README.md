dnf-behave-tests
================

dnf-behave-tests is the integration test suite for the DNF stack. It actually
contains two test suites, `dnf` and `createrepo_c`.

The test suites' directory structure is that of a behave test suite. They
contain .feature files, which contain the test scenarios, defined in steps. The
implementation of the steps is in the `steps` directory inside the respective
suites. Next to it is also the `environment.py` file, defining the global setup
of the suite. The two suites also share some common steps and utility code,
located in the `common` directory and imported into each suite's respective
codebase.

The `createrepo_c` suite is quite small and simple compared to the `dnf` suite.
The rest of this document will mainly focus on the `dnf` suite.


Generating Test Data
--------------------

To run the tests, you first need to generate the test data (which are shared by
both suites):
```
fixtures/specs/build.sh
```

This will build RPM packages from spec files defined in
`fixtures/specs/REPO_NAME` and put them into `fixtures/repos/REPO_NAME`. It
also generates gpg keys and signs the RPMs for relevant repositories and
generates ssl certificates for https.


Running the Integration Tests Directly
--------------------------------------

Besides running one of the suites in containers through the top-level
`container-test` script, you can also run it directly, e.g. in its basic form:
```
sudo behave dnf
```

This will test the `dnf` binary on your system (note that there are also a bit
ad-hoc placed `microdnf` tests inside the `dnf` test suite). If you've got your
own binary set up for testing, you can specify it:
```
sudo behave -Ddnf_command=my-dnf dnf
```

To run only scenarios of a single feature file:
```
sudo behave -Ddnf_command=my-dnf dnf/config.feature
```

You can further specify a single scenario to run by its name:
```
sudo behave -Ddnf_command=my-dnf -n "Test removal of dependency when clean_requirements_on_remove=false" dnf/config.feature
```

You can also use tags to limit which scenarios to run:
```
sudo behave -Ddnf_command=my-dnf -tbz123456 dnf/config.feature
```

Or to exclude scenarios via a tag by using `~` (this will skip any scenarios
tagged with the `use.with_os=rhel__eq__8` tag):
```
sudo behave -Ddnf_command=my-dnf -t~use.with_os=rhel__eq__8 dnf
```


### Destructive Tests

Majority of the scenarios in the `dnf` suite uses installroot and doesn't
modify the host system. The scenarios (or whole feature files) that do in some
way modify the host system (while still running `dnf` on an installroot) are
tagged with the `@destructive` tag. Scenarios which are meant to run directly
on the host system are tagged with the `@no_installroot` tag (without this tag,
the `--installroot` argument is added to any dnf command call automatically).
These are also considered destructive.

By default the `dnf` suite will not execute destructive scenarios unless you
explicitly tell it to do so. Use this with caution, not recommended outside
sandboxed environment, and usually you should only run a single destructive
test, as the tests will modify an environment shared with the tests that are
run in succession:
```
sudo behave -Ddnf_command=my-dnf -Ddestructive=yes dnf/cache.feature
```


### Working With Per-test Data

While the RPMs are built using the build script, the steps generate the
repository metadata (by calling `createrepo_c`) automatically. They also create
a default configuration file and repository configs inside the installroot.

The installroot, as well as a temporary directory to use for the tests, are
created in `/tmp` and are normally deleted after a test run. To preserve the
directories of all scenarios for inspection, use:
```
sudo behave -Ddnf_command=my-dnf -Dpreserve=y dnf
```

To preserve the directories of failing scenarios only, you can use:
```
sudo behave -Ddnf_command=my-dnf -Dpreserve=f dnf
```

dnf-bootc Test Suite
-----------
The `dnf-bootc` test suite contains tests for DNF functionality specific to
[bootc](https://github.com/containers/bootc) systems. It shares `steps` and
`environment.py` with the `dnf` suite. The tests are destructive and must be
run using [TMT](https://tmt.readthedocs.io/en/stable/) since they call
`tmt-reboot` to reboot the test system. Starting from the top level of the
ci-dnf-stack repository, you can run the `dnf-bootc` test suite with:

```
sudo dnf install -y tmt+all
sudo tmt run plan --name behave-dnf-bootc
```

Each of the features in the suite should be run on a clean bootc system, so TMT
is configured (via `tmt/plans/behave-dnf-bootc.fmf` and
`tmt/tests/test-00-bootc-install.sh`) to reinstall the DNF testing container to
the test runner via `bootc install to-existing-root` before running each
feature.

To test the effects of system reboots, scenarios in some features use the tags
`@reboot_count_1`, `@reboot_count_2`, and so on. `container-test run --reboot`
reads the environment variable `TMT_REBOOT_COUNT` and runs scenarios tagged
with `@reboot_count_$TMT_REBOOT_COUNT`. After running these scenarios, if there
are scenarios tagged `@reboot_count_${TMT_REBOOT_COUNT+1}`, `container-test`
will call `tmt-reboot` to reboot the system and run the next phase of the test.
Beware: because we need to split up scenarios with reboots, **Behave scenarios
in this test suite are not independent**, which is a departure from best
practices.


Contributing
------------

Contributions to the DNF stack test suite are welcome, but there is no
documentation on it besides this file at the moment. Please have a look around,
try to follow the established practices and don't hesitate to get in touch.
