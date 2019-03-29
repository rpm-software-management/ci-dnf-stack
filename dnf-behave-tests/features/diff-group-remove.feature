Feature: Test for swap command


Background: Enable repositories
  Given I use the repository "dnf-ci-fedora"
  Given I use the repository "dnf-ci-fedora-updates"
  Given I use the repository "dnf-ci-thirdparty"
   When I execute dnf with args "groupinstall CQRlib-non-devel"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | install       | CQRlib-extension-0:1.5-2.x86_64           |
        | group-install | CQRlib-non-devel                          |
   When I execute dnf with args "install CQRlib-devel"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |


Scenario: Remove group with "@"
   When I execute dnf with args "remove @CQRlib-non-devel"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | unchanged     | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | unchanged     | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
        | remove        | CQRlib-extension-0:1.5-2.x86_64           |
        | group-remove  | CQRlib-non-devel                          |


Scenario: Remove group with "group" command
   When I execute dnf with args "group remove CQRlib-non-devel"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | unchanged     | CQRlib-0:1.1.2-16.fc29.x86_64             |
        | unchanged     | CQRlib-devel-0:1.1.2-16.fc29.x86_64       |
        | remove        | CQRlib-extension-0:1.5-2.x86_64           |
        | group-remove  | CQRlib-non-devel                          |
