Feature: Repolist when no repositories are present

  Scenario: Repolist without arguments
       When I successfully run "dnf repolist"
       Then the command stdout should be empty

  Scenario: Repolist with "enabled"
       When I successfully run "dnf repolist enabled"
       Then the command stdout should be empty

  Scenario: Repolist with "disabled"
       When I successfully run "dnf repolist disabled"
       Then the command stdout should be empty

  Scenario: Repolist with "all"
       When I successfully run "dnf repolist all"
       Then the command stdout should be empty
