Feature: Test upgrading installonly packages


Background:
  Given I use repository "dnf-ci-fedora"


@bz1668256 @bz1616191 @bz1639429
Scenario: Install multiple versions of an installonly package with a limit of 2
  Given I set config option "installonly_limit" to "2"
   When I execute dnf with args "install kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "upgrade kernel-core"
   Then the exit code is 0
   Then stderr does not contain "cannot install both"
    And Transaction is empty
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |

