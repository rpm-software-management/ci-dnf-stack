Feature: dnf download command


Scenario: Download an RPM that doesn't exist
  Given I enable plugin "download"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "download does-not-exist"
   Then the exit code is 1
    And stderr contains "No package does-not-exist available"


Scenario: Download an existing RPM
  Given I enable plugin "download"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "download setup"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                  | sha256                                                                                        |
        | setup-2.12.1-1.fc29.noarch.rpm        | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with --verbose option
  Given I enable plugin "download"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "download setup --verbose"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                  | sha256                                                                                        |
        | setup-2.12.1-1.fc29.noarch.rpm        | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with dependencies
  Given I enable plugin "download"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "download filesystem --resolve"
   Then the exit code is 0
    And stdout contains "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                  | sha256                                                                                        |
        | filesystem-3.9-2.fc29.x86_64.rpm      | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | setup-2.12.1-1.fc29.noarch.rpm        | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with dependencies into a --destdir
  Given I enable plugin "download"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "download filesystem --resolve --destdir={context.dnf.tempdir}"
   Then the exit code is 0
    And stdout contains "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                          | sha256                                                                                        |
        | {context.dnf.tempdir}/filesystem-3.9-2.fc29.x86_64.rpm        | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm          | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with dependencies into a --destdir where a dependency is installed
  Given I enable plugin "download"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "download basesystem --resolve --destdir={context.dnf.tempdir}"
   Then the exit code is 0
    And stdout contains "basesystem-11-6.fc29.noarch.rpm"
    And stdout contains "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout does not contain "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                          | sha256                                                                                        |
        | {context.dnf.tempdir}/basesystem-11-6.fc29.noarch.rpm         | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm   |
        | {context.dnf.tempdir}/filesystem-3.9-2.fc29.x86_64.rpm        | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm          | -                                                                                             |


Scenario: Download an existing RPM with dependencies into a --destdir where all packages are already installed
  Given I enable plugin "download"
    And I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | basesystem-0:11-6.fc29.noarch         |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "download basesystem --resolve --destdir={context.dnf.tempdir}"
   Then the exit code is 0
    And stdout contains "basesystem-11-6.fc29.noarch.rpm"
    And stdout does not contain "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout does not contain "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                          | sha256                                                                                        |
        | {context.dnf.tempdir}/basesystem-11-6.fc29.noarch.rpm         | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm   |
        | {context.dnf.tempdir}/filesystem-3.9-2.fc29.x86_64.rpm        | -                                                                                             |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm          | -                                                                                             |
