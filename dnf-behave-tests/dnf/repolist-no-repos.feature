Feature: Repo list (alias repolist) when there are no repositories


Scenario: Repolist without arguments
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories were loaded from the installroot. To use the configuration and repositories of the host system, pass --use-host-config."


Scenario: Repo list with "--enabled"
   When I execute dnf with args "repo list --enabled"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No repositories were loaded from the installroot. To use the configuration and repositories of the host system, pass --use-host-config."


Scenario: Repo list with "--disabled"
   When I execute dnf with args "repo list --disabled"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No matches found."


Scenario: Repo list with "--all"
   When I execute dnf with args "repo list --all"
   Then the exit code is 0
    And stdout is empty
    And stderr contains "No matches found."
