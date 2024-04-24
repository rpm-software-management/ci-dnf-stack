Feature: dnf download --debuginfo command


Background:
  Given I set working directory to "{context.dnf.tempdir}"


Scenario: Download a debuginfo for an RPM that doesn't exist
  Given I use repository "dnf-ci-fedora" as http
   When I execute dnf with args "download --debuginfo does-not-exist"
   Then the exit code is 1
    And stderr contains "No package does-not-exist available"


Scenario: Download a debuginfo for an existing RPM
  Given I use repository "dnf-ci-fedora-updates" as http
   When I execute dnf with args "download --debuginfo libzstd"
   Then the exit code is 0
    And stdout contains "libzstd-debuginfo-1.3.6-1.fc29.x86_64.rpm"
    And file sha256 checksums are following
        | Path                                                              | sha256                                                                                                        |
        | {context.dnf.tempdir}/libzstd-debuginfo-1.3.6-1.fc29.x86_64.rpm   | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/libzstd-debuginfo-1.3.6-1.fc29.x86_64.rpm |


Scenario: Download a debuginfo for an existing RPM with a different name
  Given I use repository "dnf-ci-fedora" as http
   When I execute dnf with args "download --debuginfo nscd"
   Then the exit code is 0
    And stdout contains "glibc-debuginfo-2.28-9.fc29.x86_64.rpm"
    And stdout does not contain "glibc-debuginfo-common-2.28-9.fc29.x86_64.rpm"
    And file sha256 checksums are following
        | Path                                                                  | sha256                                                                                                |
        | {context.dnf.tempdir}/glibc-debuginfo-2.28-9.fc29.x86_64.rpm          | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora/x86_64/glibc-debuginfo-2.28-9.fc29.x86_64.rpm    |
        | {context.dnf.tempdir}/glibc-debuginfo-common-2.28-9.fc29.x86_64.rpm   | -                                                                                                     |

# TODO: glibc-debuginfo-common should be ideally downloaded as well


Scenario: Download an existing --debuginfo RPM with --verbose option
  Given I use repository "dnf-ci-fedora-updates" as http
   When I execute dnf with args "download --debuginfo libzstd --verbose"
   Then the exit code is 0
    And stdout contains "libzstd-debuginfo-1.3.6-1.fc29.x86_64.rpm"
    And file sha256 checksums are following
        | Path                                                              | sha256                                                                                                        |
        | {context.dnf.tempdir}/libzstd-debuginfo-1.3.6-1.fc29.x86_64.rpm   | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/libzstd-debuginfo-1.3.6-1.fc29.x86_64.rpm |


Scenario: Download debuginfo for all architectures
  Given I use repository "dnf-ci-fedora-updates" as http
   When I execute dnf with args "download --debuginfo lz4"
   Then the exit code is 0
    And stdout contains "lz4-debuginfo-1.8.2-2.fc29.i686.rpm"
    And stdout contains "lz4-debuginfo-1.8.2-2.fc29.x86_64.rpm"
    And file sha256 checksums are following
        | Path                                                         | sha256                                                                                                     |
        | {context.dnf.tempdir}/lz4-debuginfo-1.8.2-2.fc29.i686.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/i686/lz4-debuginfo-1.8.2-2.fc29.i686.rpm      |
        | {context.dnf.tempdir}/lz4-debuginfo-1.8.2-2.fc29.x86_64.rpm  | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/lz4-debuginfo-1.8.2-2.fc29.x86_64.rpm  |


@bz1637008
Scenario: Download debugsource for an RPM that doesn't exist
  Given I use repository "dnf-ci-fedora" as http
   When I execute dnf with args "download --debugsource does-not-exist"
   Then the exit code is 1
    And stderr contains "No package does-not-exist available"


@bz1637008
Scenario: Download debugsource for an existing RPM
  Given I use repository "dnf-ci-fedora-updates" as http
   When I execute dnf with args "download --debugsource libzstd"
   Then the exit code is 0
    And stdout contains "zstd-debugsource-1.3.6-1.fc29.x86_64.rpm"
    And file sha256 checksums are following
        | Path                                                             | sha256                                                                                                       |
        | {context.dnf.tempdir}/zstd-debugsource-1.3.6-1.fc29.x86_64.rpm   | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/zstd-debugsource-1.3.6-1.fc29.x86_64.rpm |


@bz1637008
Scenario: Download source, debuginfo and debugsource for an existing RPM
  Given I use repository "dnf-ci-fedora-updates" as http
   When I execute dnf with args "download --source --debuginfo --debugsource libzstd"
   Then the exit code is 0
    And stdout contains "zstd-1.3.6-1.fc29.src.rpm"
    # the file name below is cut off in the output table
    And stdout contains "libzstd-debuginfo-1.3.6-1.fc29.x86_64.rp"
    And stdout contains "zstd-debugsource-1.3.6-1.fc29.x86_64.rpm"
    And file sha256 checksums are following
        | Path                                                              | sha256                                                                                                        |
        | {context.dnf.tempdir}/zstd-1.3.6-1.fc29.src.rpm                   | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/src/zstd-1.3.6-1.fc29.src.rpm                    |
        | {context.dnf.tempdir}/libzstd-debuginfo-1.3.6-1.fc29.x86_64.rpm   | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/libzstd-debuginfo-1.3.6-1.fc29.x86_64.rpm |
        | {context.dnf.tempdir}/zstd-debugsource-1.3.6-1.fc29.x86_64.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/zstd-debugsource-1.3.6-1.fc29.x86_64.rpm  |


@bz1637008
Scenario: Download debugsource for all architectures
  Given I use repository "dnf-ci-fedora-updates" as http
   When I execute dnf with args "download --debugsource lz4"
   Then the exit code is 0
    And stdout contains "lz4-debugsource-1.8.2-2.fc29.i686.rpm"
    And stdout contains "lz4-debugsource-1.8.2-2.fc29.x86_64.rpm"
    And file sha256 checksums are following
        | Path                                                           | sha256                                                                                                       |
        | {context.dnf.tempdir}/lz4-debugsource-1.8.2-2.fc29.i686.rpm    | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/i686/lz4-debugsource-1.8.2-2.fc29.i686.rpm      |
        | {context.dnf.tempdir}/lz4-debugsource-1.8.2-2.fc29.x86_64.rpm  | file://{context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/lz4-debugsource-1.8.2-2.fc29.x86_64.rpm  |
