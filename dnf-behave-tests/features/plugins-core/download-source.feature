@fixture.httpd
Feature: dnf download --source command


Background:
  Given I enable plugin "download"
    And I use repository "dnf-ci-fedora" as http
    And I set working directory to "{context.dnf.tempdir}"


Scenario: Download a source for an RPM that doesn't exist
   When I execute dnf with args "download --source does-not-exist"
   Then the exit code is 1
    And stderr contains "No package does-not-exist available"


Scenario: Download a source for an existing RPM
   When I execute dnf with args "download --source setup"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.src.rpm"
    And file sha256 checksums are following
        | Path                                              | sha256                                                                                |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.src.rpm | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/src/setup-2.12.1-1.fc29.src.rpm  |


Scenario: Download a source for an existing RPM with a different name
   When I execute dnf with args "download --source nscd"
   Then the exit code is 0
    And stdout contains "glibc-2.28-9.fc29.src.rpm"
    And file sha256 checksums are following
        | Path                                              | sha256                                                                                |
        | {context.dnf.tempdir}/glibc-2.28-9.fc29.src.rpm   | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/src/glibc-2.28-9.fc29.src.rpm    |


Scenario: Download an existing --source RPM with --verbose option
   When I execute dnf with args "download --source setup --verbose"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.src.rpm"
    And file sha256 checksums are following
        | Path                                              | sha256                                                                |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.src.rpm | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/src/setup-2.12.1-1.fc29.src.rpm  |


@bz1649627
Scenario: Download a specified source rpm
   When I execute dnf with args "download --destdir={context.dnf.tempdir}/downloaddir --source setup-2.12.1-1.fc29.src"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.src.rpm"
    And stdout does not contain "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                              | sha256                                                                                |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.src.rpm     | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/src/setup-2.12.1-1.fc29.src.rpm  |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm  | -                                                                                     |


@bz1649627
Scenario Outline: Download a source RPM when there are more versions available
  Given I use repository "dnf-ci-fedora-updates-testing" as http
   When I execute dnf with args "download --source <pkgspec>"
   Then the exit code is 0
    And stdout contains "<srpm>"
    And file sha256 checksums are following
        | Path                          | sha256                                                    |
        | {context.dnf.tempdir}/<srpm>  | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates-testing/src/<srpm>  |

Examples:
  | pkgspec                     | srpm                           |
  | wget                        | wget-1.19.5-5.fc29.src.rpm     |
  | wget-1.19.4-1.fc29          | wget-1.19.4-1.fc29.src.rpm     |
  | wget-1.19.5-5.fc29          | wget-1.19.5-5.fc29.src.rpm     |
  | wget-1.19.4-1.fc29.src      | wget-1.19.4-1.fc29.src.rpm     |
  | wget-1.19.5-5.fc29.src      | wget-1.19.5-5.fc29.src.rpm     |
  | wget-1.19.4-1.fc29.x86_64   | wget-1.19.4-1.fc29.src.rpm     |
  | wget-1.19.5-5.fc29.x86_64   | wget-1.19.5-5.fc29.src.rpm     |


@xfail
Scenario Outline: Download a source RPM when there are more epochs available
  Given I use repository "dnf-ci-fedora-updates-testing" as http
   When I execute dnf with args "download --source <pkgspec>"
   Then the exit code is 0
    And stdout contains "<srpm>"
    And file sha256 checksums are following
        | Path                          | sha256                                                    |
        | {context.dnf.tempdir}/<srpm>  | file://{context.dnf.fixturesdir}/repos/<repo>/src/<srpm>  |

Examples:
  | pkgspec                     | repo                           | srpm                           |
  | wget-0:1.19.5-5.fc29        | dnf-ci-fedora                  | wget-1.19.5-5.fc29.src.rpm     |
  | wget-1:1.19.4-1.fc29        | dnf-ci-fedora-updates-testing  | wget-1.19.4-1.fc29.src.rpm     |
  | wget-1:1.19.5-5.fc29        | dnf-ci-fedora-updates-testing  | wget-1.19.5-5.fc29.src.rpm     |
  | wget-0:1.19.5-5.fc29.src    | dnf-ci-fedora                  | wget-1.19.5-5.fc29.src.rpm     |
  | wget-1:1.19.4-1.fc29.src    | dnf-ci-fedora-updates-testing  | wget-1.19.4-1.fc29.src.rpm     |
  | wget-1:1.19.5-5.fc29.src    | dnf-ci-fedora-updates-testing  | wget-1.19.5-5.fc29.src.rpm     |
  | wget-0:1.19.5-5.fc29.x86_64 | dnf-ci-fedora                  | wget-1.19.5-5.fc29.src.rpm     |
  | wget-1:1.19.4-1.fc29.x86_64 | dnf-ci-fedora-updates-testing  | wget-1.19.4-1.fc29.src.rpm     |
  | wget-1:1.19.5-5.fc29.x86_64 | dnf-ci-fedora-updates-testing  | wget-1.19.5-5.fc29.src.rpm     |


# TODO: --source --resolve doesn't work correctly; see see bug 1571251
