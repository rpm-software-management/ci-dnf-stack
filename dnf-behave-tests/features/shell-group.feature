Feature: Shell group


Scenario: Using dnf shell, fail to install a non-existent package group
   When I open dnf shell session
    And I execute in dnf shell "repo enable dnf-ci-fedora"
    And I execute in dnf shell "group install NoSuchGroup"
   Then stdout contains "Warning: Module or Group '.*NoSuchGroup.*' does not exist\."
    And I execute in dnf shell "run"
   Then Transaction is empty
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"


Scenario: Using dnf shell, fail to remove a non-existent package group
   When I open dnf shell session
    And I execute in dnf shell "repo enable dnf-ci-fedora"
    And I execute in dnf shell "group remove NoSuchGroup"
   Then stdout contains "Warning: Group '.*NoSuchGroup.*' is not installed\."
    And I execute in dnf shell "run"
   Then Transaction is empty
   When I execute in dnf shell "exit"
   Then stdout contains "Leaving Shell"
