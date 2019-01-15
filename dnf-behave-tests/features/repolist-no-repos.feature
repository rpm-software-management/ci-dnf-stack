Feature: Repolist when there are no repositories


Scenario: Repolist without arguments
  Given There are no repositories
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories available"


Scenario: Repolist with "enabled"
  Given There are no repositories
   When I execute dnf with args "repolist enabled"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories available"


Scenario: Repolist with "disabled"
  Given There are no repositories
   When I execute dnf with args "repolist disabled"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories available"


Scenario: Repolist with "all"
  Given There are no repositories
   When I execute dnf with args "repolist all"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories available"
