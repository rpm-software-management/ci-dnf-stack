Feature: Comment transaction


Background: Set up dnf-ci-fedora repository
  Given I use repository "dnf-ci-fedora"
  And I successfully execute dnf with args "install abcde --comment this_is_a_comment"


@bz1773679
Scenario: history info shows comment to transaction
  When I execute dnf with args "history info"
  Then the exit code is 0
  Then stdout contains "Comment        : this_is_a_comment"


Scenario: history info for installing a group
  Given I use repository "dnf-ci-thirdparty"
   When I execute dnf with args "group install DNF-CI-Testgroup"
   Then the exit code is 0
    And History info should match
        | Key           | Value                         |
        | Return-Code   | Success                       |
        | Install       | filesystem-3.9-2.fc29.x86_64  |
        | Install       | lame-3.100-4.fc29.x86_64      |
        | Install       | lame-libs-3.100-4.fc29.x86_64 |
        | Install       | setup-2.12.1-1.fc29.noarch    |
        | Install       | @dnf-ci-testgroup             |


Scenario: history info for installing a group when there are upgrades
  Given I successfully execute dnf with args "install lame"
    And I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "group install dnf-ci-testgroup"
   Then the exit code is 0
    And History info should match
        | Key           | Value                         |
        | Return-Code   | Success                       |
        | Install       | filesystem-3.9-2.fc29.x86_64  |
        | Install       | setup-2.12.1-1.fc29.noarch    |
        | Upgrade       | lame-3.100-5.fc29.x86_64      |
        | Upgraded      | lame-3.100-4.fc29.x86_64      |
        | Upgrade       | lame-libs-3.100-5.fc29.x86_64 |
        | Upgraded      | lame-libs-3.100-4.fc29.x86_64 |
        | Install       | @dnf-ci-testgroup             |
