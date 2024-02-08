@dnf5
Feature: Repo list (alias repolist) when all repositories are disabled

Background:
  Given I use repository "dnf-ci-fedora" with configuration
        |key      | value |
        | enabled | 0     |


Scenario: Repolist without arguments
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout is empty


Scenario: Repo list with "--enabled"
   When I execute dnf with args "repo list --enabled"
   Then the exit code is 0
    And stdout is empty


Scenario: Repo list with "--disabled"
   When I execute dnf with args "repo list --disabled"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora"


Scenario: Repo list with "--all"
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "repo list --all"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora test repository\s+disabled"
    And stdout contains "dnf-ci-fedora-updates\s+dnf-ci-fedora-updates test repository\s+enabled"
