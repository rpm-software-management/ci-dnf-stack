Feature: Repolist when all repositories are disabled


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
    And stdout contains "dnf-ci-fedora-updates\s+dnf-ci-fedora-updates"
    And stdout contains "dnf-ci-thirdparty\s+dnf-ci-thirdparty"
    And stdout contains "dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates"


Scenario: Repolist with "all"
   When I execute dnf with args "repolist all"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora\s+disabled"
    And stdout contains "dnf-ci-fedora-updates\s+dnf-ci-fedora-updates\s+disabled"
    And stdout contains "dnf-ci-thirdparty\s+dnf-ci-thirdparty\s+disabled"
    And stdout contains "dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates\s+disabled"
