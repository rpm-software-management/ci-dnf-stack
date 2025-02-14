# --duplicates is missing: https://github.com/rpm-software-management/dnf5/issues/760
@xfail
Feature: Remove duplicate RPMs


@bz1674296
Scenario: Remove a duplicate RPM
  Given I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/flac-1.3.3-1.fc29.x86_64.rpm"
   Then the exit code is 0
  Given I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/flac-1.3.3-3.fc29.x86_64.rpm"
   Then the exit code is 0
   When I execute dnf with args "remove --duplicates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | remove        | flac-0:1.3.3-1.fc29.x86_64            |



@bz1674296
@bz1647345
Scenario: Remove multiple duplicate RPMs
  Given I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/flac-1.3.3-1.fc29.x86_64.rpm"
   Then the exit code is 0
  Given I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/flac-1.3.3-1.fc29.x86_64.rpm --force"
   Then the exit code is 0
  Given I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/flac-1.3.3-1.fc29.x86_64.rpm --force"
   Then the exit code is 0
  Given I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/flac-1.3.3-3.fc29.x86_64.rpm"
   Then the exit code is 0
   When I execute dnf with args "remove --duplicates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | remove        | flac-0:1.3.3-1.fc29.x86_64            |


@bz1674296
Scenario: Remove a duplicate RPM and reinstall an existing RPM when a copy is available in repos
  Given I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/flac-1.3.3-1.fc29.x86_64.rpm"
   Then the exit code is 0
  Given I execute rpm with args "-i {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/flac-1.3.3-3.fc29.x86_64.rpm"
   Then the exit code is 0
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "remove --duplicates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | reinstall     | flac-0:1.3.3-3.fc29.x86_64            |
        | obsoleted     | flac-0:1.3.3-1.fc29.x86_64            |
