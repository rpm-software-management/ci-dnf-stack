Feature: Transaction history rollback


Background:
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"


Scenario: Rollback
  Given I successfully execute dnf with args "install basesystem"
    And I successfully execute dnf with args "install glibc-2.28-26.fc29.x86_64"
    And I successfully execute dnf with args "downgrade glibc"
    And I successfully execute dnf with args "upgrade glibc"
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | glibc-2.28-26.fc29.x86_64                  |
        | remove        | glibc-all-langpacks-2.28-26.fc29.x86_64    |
        | remove        | glibc-common-2.28-26.fc29.x86_64           |


Scenario: Multiple rollbacks
  Given I successfully execute dnf with args "install basesystem"
    And I successfully execute dnf with args "install glibc-2.28-26.fc29.x86_64"
    And I successfully execute dnf with args "downgrade glibc"
    And I successfully execute dnf with args "upgrade glibc"
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | glibc-2.28-26.fc29.x86_64                  |
        | remove        | glibc-all-langpacks-2.28-26.fc29.x86_64    |
        | remove        | glibc-common-2.28-26.fc29.x86_64           |
   When I execute dnf with args "history rollback 2"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install       | glibc-2.28-26.fc29.x86_64                  |
        | install       | glibc-all-langpacks-2.28-26.fc29.x86_64    |
        | install       | glibc-common-2.28-26.fc29.x86_64           |
