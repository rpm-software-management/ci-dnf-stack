@fixture.httpd
Feature: dnf download --source command


Background:
  Given I enable plugin "download"
    And I use the http repository based on "dnf-ci-fedora"


Scenario: Download a source for an RPM that doesn't exist
   When I execute dnf with args "download --source does-not-exist"
   Then the exit code is 1
    And stderr contains "No package does-not-exist available"


Scenario: Download a source for an existing RPM
   When I execute dnf with args "download --source setup"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.src.rpm"
    And file sha256 checksums are following
        | Path                                  | sha256                                                                                |
        | setup-2.12.1-1.fc29.src.rpm           | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/src/setup-2.12.1-1.fc29.src.rpm  |


Scenario: Download a source for an existing RPM with a different name
   When I execute dnf with args "download --source nscd"
   Then the exit code is 0
    And stdout contains "glibc-2.28-9.fc29.src.rpm"
    And file sha256 checksums are following
        | Path                                  | sha256                                                                                |
        | glibc-2.28-9.fc29.src.rpm             | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/src/glibc-2.28-9.fc29.src.rpm    |


Scenario: Download an existing --source RPM with --verbose option
   When I execute dnf with args "download --source setup --verbose"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.src.rpm"
    And file sha256 checksums are following
        | Path                                  | sha256                                                                |
        | setup-2.12.1-1.fc29.src.rpm           | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/src/setup-2.12.1-1.fc29.src.rpm  |


@bz1649627
Scenario: Download a specified source rpm
   When I execute dnf with args "download --destdir={context.dnf.tempdir} --source setup-2.12.1-1.fc29.src"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.src.rpm"
    And stdout does not contain "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                  | sha256                                                                                |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.src.rpm     | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/src/setup-2.12.1-1.fc29.src.rpm  |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm  | -                                                                                     |


# TODO: --source --resolve doesn't work correctly; see see bug 1571251
