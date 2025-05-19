Feature: Comment transaction


Background: Set up dnf-ci-fedora repository
  Given I use repository "dnf-ci-fedora"
  And I successfully execute dnf with args "install abcde --comment this_is_a_comment"


# @dnf5
# TODO(nsella) different stdout
@bz1773679
Scenario: history info shows comment to transaction
  When I execute dnf with args "history info"
  Then the exit code is 0
  Then stdout contains "Comment        : this_is_a_comment"


# @dnf5
# TODO(nsella) Unknown argument "install" for command "group"
@bz1845800
Scenario: history info for installing a group
  Given I use repository "dnf-ci-thirdparty"
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And History info should match
        | Key           | Value                         |
        | Return-Code   | Success                       |
        | Persistence   | Persist                       |
        | Install       | filesystem-3.9-2.fc29.x86_64  |
        | Install       | lame-3.100-4.fc29.x86_64      |
        | Install       | lame-libs-3.100-4.fc29.x86_64 |
        | Install       | setup-2.12.1-1.fc29.noarch    |
        | Install       | @dnf-ci-testgroup             |


# @dnf5
# TODO(nsella) Unknown argument "install" for command "group"
@bz1845800
Scenario: history info for installing a group when there are upgrades
  Given I successfully execute dnf with args "install lame"
    And I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "group install dnf-ci-testgroup"
   Then the exit code is 0
    And History info should match
        | Key           | Value                         |
        | Return-Code   | Success                       |
        | Persistence   | Persist                       |
        | Install       | filesystem-3.9-2.fc29.x86_64  |
        | Install       | setup-2.12.1-1.fc29.noarch    |
        | Upgrade       | lame-3.100-5.fc29.x86_64      |
        | Upgraded      | lame-3.100-4.fc29.x86_64      |
        | Upgrade       | lame-libs-3.100-5.fc29.x86_64 |
        | Upgraded      | lame-libs-3.100-4.fc29.x86_64 |
        | Install       | @dnf-ci-testgroup             |


@xfail
@RHEL-81778
@RHEL-81779
Scenario: history info range - two upgrade actions should be reported as upgrade
  Given I use repository "history-info"
    And I successfully execute dnf with args "install rsyslog-8.2102.0-1.el9"
    And I successfully execute dnf with args "update rsyslog-8.2102.0-2.el9"
   When I execute dnf with args "update rsyslog-8.2102.0-3.el9"
   Then the exit code is 0
    And History info "last-1..last" should match
        | Key           | Value                              |
        | Persistence   | Persist                       |
        | Upgrade       | rsyslog-8.2102.0-1.el9.x86_64      |
        | Upgraded      | rsyslog-8.2102.0-3.el9.x86_64      |
