Feature: Repolist when all repositories are disabled

Background:
  Given I use repository "dnf-ci-fedora" with configuration
        |key      | value |
        | enabled | 0     |


Scenario: Repolist without arguments
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout is empty


Scenario: Repolist with "enabled"
   When I execute dnf with args "repolist enabled"
   Then the exit code is 0
    And stdout is empty


Scenario: Repolist with "disabled"
   When I execute dnf with args "repolist disabled"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora"


Scenario: Repolist with "all"
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "repolist all"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora test repository\s+disabled"
    And stdout contains "dnf-ci-fedora-updates\s+dnf-ci-fedora-updates test repository\s+enabled"
