Feature: Help command

Scenario: General help
   When I execute dnf with args "--help"
   Then the exit code is 0
    And stdout contains "List of Main Commands"
   When I execute dnf with args "--unknown-option"
   Then the exit code is 0
    And stdout contains "List of Main Commands"
   When I execute dnf with args "help"
   Then the exit code is 0
    And stdout contains "List of Main Commands"
   When I execute dnf with args "unknown-command"
   Then the exit code is 1
    And stderr contains "No such command"
    And stderr contains "It could be a DNF plugin command"


Scenario: Command help
   When I execute dnf with args "help install"
   Then the exit code is 0
   And stdout contains "usage: dnf install"
   When I execute dnf with args "install --help"
   Then the exit code is 0
    And stdout contains "usage: dnf install"
   When I execute dnf with args "install --unknown-option"
   Then the exit code is 2
    And stderr contains "usage: dnf install"
