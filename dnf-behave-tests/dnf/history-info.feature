@dnf5
Feature: History info command


Background: Set up dnf-ci-fedora repository
  Given I use repository "dnf-ci-fedora"
  And I successfully execute dnf with args "install abcde --comment this_is_a_comment"


@bz1773679
Scenario: history info shows comment to transaction
  When I execute dnf with args "history info"
  Then the exit code is 0
  Then stdout contains "Comment          : this_is_a_comment"


@bz1845800
Scenario: history info for installing a group
  Given I use repository "dnf-ci-thirdparty"
   When I execute dnf with args "group install dnf-ci-testgroup"
   Then the exit code is 0
    And History info should match
        | Key           | Value                           |
        | Status        | Ok                              |
        | Install       | filesystem-0:3.9-2.fc29.x86_64  |
        | Install       | lame-0:3.100-4.fc29.x86_64      |
        | Install       | setup-0:2.12.1-1.fc29.noarch    |
        | Install       | lame-libs-0:3.100-4.fc29.x86_64 |


@bz1845800
Scenario: history info for installing a group when there are upgrades
  Given I successfully execute dnf with args "install lame"
    And I use repository "dnf-ci-thirdparty"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "group install dnf-ci-testgroup"
   Then the exit code is 0
    And History info should match
        | Key           | Value                           |
        | Status        | Ok                              |
        | Install       | filesystem-0:3.9-2.fc29.x86_64  |
        | Install       | setup-0:2.12.1-1.fc29.noarch    |
        | Upgrade       | lame-0:3.100-5.fc29.x86_64      |
        | Upgrade       | lame-libs-0:3.100-5.fc29.x86_64 |
        | Replaced      | lame-0:3.100-4.fc29.x86_64      |
        | Replaced      | lame-libs-0:3.100-4.fc29.x86_64 |
