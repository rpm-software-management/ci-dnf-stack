Feature: dnf download command


Background:
  Given I enable plugin "download"


@bz1463723
Scenario: Download an existing RPM in file:// mode
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "download setup --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And file sha256 checksums are following
        | Path                                                              | sha256                                                                                     |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm  | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm |


Scenario: Download an existing RPM in file:// mode with all dependencies into a --destdir
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "download basesystem --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm      | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |
        | {context.dnf.tempdir}/downloaddir/basesystem-11-6.fc29.noarch.rpm     | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm   |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |

@bz1787908
Scenario: Download an existing RPM in file:// mode with all dependencies into a --destdir when it is in multiple repositories
  Given I use repository "dnf-ci-fedora"
# Add dnf-ci-fedora-updates repository with identical metadata of dnf-ci-fedora
    And I use repository "dnf-ci-fedora-updates" with configuration
        | key             | value                                       |
        | baseurl         | file:///opt/behave/fixtures/repos/dnf-ci-fedora  |
   When I execute dnf with args "download basesystem --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                        |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm      | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm    |
        | {context.dnf.tempdir}/downloaddir/basesystem-11-6.fc29.noarch.rpm     | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm   |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm  |

@bz1787908
Scenario: Download an existing RPM in two versions in file:// mode with all dependencies into a --destdir
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "download glibc-2.28-9.fc29 glibc-0:2.28-26.fc29.x86_64 --resolve --destdir={context.dnf.tempdir}/downloaddir"
   Then the exit code is 0
    And file sha256 checksums are following
        | Path                                                                            | sha256                                                                                                           |
        | {context.dnf.tempdir}/downloaddir/setup-2.12.1-1.fc29.noarch.rpm                | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/setup-2.12.1-1.fc29.noarch.rpm                       |
        | {context.dnf.tempdir}/downloaddir/basesystem-11-6.fc29.noarch.rpm               | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/noarch/basesystem-11-6.fc29.noarch.rpm                      |
        | {context.dnf.tempdir}/downloaddir/glibc-2.28-26.fc29.x86_64.rpm                 | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/glibc-2.28-26.fc29.x86_64.rpm                |
        | {context.dnf.tempdir}/downloaddir/glibc-2.28-9.fc29.x86_64.rpm                  | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/glibc-2.28-9.fc29.x86_64.rpm                         |
        | {context.dnf.tempdir}/downloaddir/glibc-all-langpacks-2.28-26.fc29.x86_64.rpm   | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/glibc-all-langpacks-2.28-26.fc29.x86_64.rpm  |
        | {context.dnf.tempdir}/downloaddir/glibc-all-langpacks-2.28-9.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/glibc-all-langpacks-2.28-9.fc29.x86_64.rpm           |
        | {context.dnf.tempdir}/downloaddir/glibc-common-2.28-26.fc29.x86_64.rpm          | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/glibc-common-2.28-26.fc29.x86_64.rpm         |
        | {context.dnf.tempdir}/downloaddir/glibc-common-2.28-9.fc29.x86_64.rpm           | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/glibc-common-2.28-9.fc29.x86_64.rpm                  |
        | {context.dnf.tempdir}/downloaddir/filesystem-3.9-2.fc29.x86_64.rpm              | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/filesystem-3.9-2.fc29.x86_64.rpm                     |
