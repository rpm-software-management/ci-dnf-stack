Feature: dnf download command


Background:
  Given I enable plugin "download"
    And I use repository "dnf-ci-fedora" as http
    And I set working directory to "{context.dnf.tempdir}"


Scenario: Download an RPM that doesn't exist
   When I execute dnf with args "download does-not-exist"
   Then the exit code is 1
    And stderr contains "No package does-not-exist available"


Scenario: Download an existing RPM
   When I execute dnf with args "download setup"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm  | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with --verbose option
   When I execute dnf with args "download setup --verbose"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm  | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with dependencies
   When I execute dnf with args "download filesystem --resolve"
   Then the exit code is 0
    And stdout contains "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                      | sha256                                                                                        |
        | {context.dnf.tempdir}/filesystem-3.9-2.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/setup-2.12.1-1.fc29.noarch.rpm      | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


@bz1844925
Scenario: Error when failed to resolve dependencies
   When I execute dnf with args "download filesystem --resolve --exclude setup"
   Then the exit code is 1
    And stderr is
        """
        Error in resolve of packages:
            filesystem-3.9-2.fc29.x86_64

         Problem: package filesystem-3.9-2.fc29.x86_64 from dnf-ci-fedora requires setup, but none of the providers can be installed
          - conflicting requests
          - package setup-2.12.1-1.fc29.noarch from dnf-ci-fedora is filtered out by exclude filtering
        """


Scenario: Download an existing RPM with dependencies into a --destdir
   When I execute dnf with args "download filesystem --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And stdout contains "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm      | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |


Scenario: Download an existing RPM with dependencies into a --destdir where a dependency is installed
   When I execute dnf with args "install setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "download basesystem --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And stdout contains "basesystem-11-6.fc29.noarch.rpm"
    And stdout contains "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout does not contain "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/downloaddir/basesystem-11-6.fc29.noarch.rpm     | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm   |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm      | -                                                                                             |


Scenario: Download an existing RPM with dependencies into a --destdir where all packages are already installed
   When I execute dnf with args "install basesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | basesystem-0:11-6.fc29.noarch         |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64        |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch          |
   When I execute dnf with args "download basesystem --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And stdout contains "basesystem-11-6.fc29.noarch.rpm"
    And stdout does not contain "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout does not contain "setup-2.12.1-1.fc29.noarch.rpm"
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/downloaddir/basesystem-11-6.fc29.noarch.rpm     | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm   |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm    | -                                                                                             |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm      | -                                                                                             |

@bz1612874
Scenario: Download an existing RPM when there are multiple packages of the same NEVRA
  Given I use repository "dnf-ci-gpg" as http
   When I execute dnf with args "download --destdir={context.dnf.installroot}/tmp/download setup filesystem wget"
   Then the exit code is 0
    And stdout contains "setup-2.12.1-1.fc29.noarch.rpm"
    And stdout contains "filesystem-3.9-2.fc29.x86_64.rpm"
    And stdout contains "wget-1.19.5-5.fc29.x86_64.rpm"
      # check that each file was being downloaded only once
      # By default re.search() (used by "stdout does not contain") does not match
      # across multiple lines. To bypass this limitation and check that the package
      # name is not present on multiple lines, use "(.|\n)*" pattern instead of ".*".
    And stdout does not contain "setup(.|\n)*setup"
    And stdout does not contain "filesystem(.|\n)*filesystem"
    And stdout does not contain "wget(.|\n)*wget"
      # check that the files have been downloaded
    And file "/tmp/download/setup-2.12.1-1.fc29.noarch.rpm" exists
    And file "/tmp/download/filesystem-3.9-2.fc29.x86_64.rpm" exists
    And file "/tmp/download/wget-1.19.5-5.fc29.x86_64.rpm" exists
