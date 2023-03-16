@dnf5
Feature: Check exit codes of upgrade command


Background: Install RPMs
  Given I use repository "simple-base"


Scenario: Test exit code when no upgrade needed
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And stderr is empty


Scenario: Test exit code when package is already on the highest version
  Given I successfully execute dnf with args "install labirinto"
   When I execute dnf with args "upgrade labirinto"
   Then the exit code is 0
    And stderr is empty


Scenario: Test exit code for non-existent package
   When I execute dnf with args "upgrade non-existent"
   Then the exit code is 1
    And stderr is
    """
    Failed to resolve the transaction:
    No match for argument: non-existent
    """


Scenario: Test exit code for uninstalled package
   When I execute dnf with args "upgrade labirinto"
   Then the exit code is 1
    And stderr is
    """
    Failed to resolve the transaction:
    Packages for argument 'labirinto' available, but not installed.
    """


Scenario: Test exit code for uninstalled and non-existent package
   When I execute dnf with args "upgrade labirinto non-existent"
   Then the exit code is 1
    And stderr is
    """
    Failed to resolve the transaction:
    Packages for argument 'labirinto' available, but not installed.
    No match for argument: non-existent
    """


Scenario: Test exit code when one package is upgradable and the other non-existent
  Given I successfully execute dnf with args "install labirinto"
    And I use repository "simple-updates"
   When I execute dnf with args "upgrade non-existent labirinto"
   Then the exit code is 0
    And stderr is
    """
    No match for argument: non-existent
    """


Scenario: Test exit code when one package is upgradable and the other uninstalled
  Given I successfully execute dnf with args "install labirinto"
    And I use repository "simple-updates"
   When I execute dnf with args "upgrade vagare labirinto"
   Then the exit code is 0
    And stderr is
    """
    Packages for argument 'vagare' available, but not installed.
    """
