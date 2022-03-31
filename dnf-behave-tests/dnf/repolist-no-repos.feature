# @dnf5
# TODO(nsella) different stdout
Feature: Repolist when there are no repositories


Scenario: Repolist without arguments
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories available"


Scenario: Repolist with "enabled"
   When I execute dnf with args "repolist enabled"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories available"


Scenario: Repolist with "disabled"
   When I execute dnf with args "repolist disabled"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories available"


Scenario: Repolist with "all"
   When I execute dnf with args "repolist all"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories available"
