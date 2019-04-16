Feature: Test for alias command

Background:
   When I execute dnf with args "alias add inthrone=install"
   Then the exit code is 0
    And stdout contains "^Aliases added: inthrone$"


Scenario: Add alias


@not.with_os=rhel__eq__8
@bz1666325
Scenario: List aliases
   When I execute dnf with args "alias list"
   Then the exit code is 0
   And stdout contains "Alias inthrone='install'"


Scenario: Use alias
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "inthrone setup"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Delete alias
   When I execute dnf with args "alias delete inthrone"
   Then the exit code is 0
    And stdout contains "^Aliases deleted: inthrone$"
   When I execute dnf with args "alias list"
   Then the exit code is 0
   And stdout does not contain "Alias inthrone"
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "inthrone setup"
   Then the exit code is 1
    And stderr contains "No such command: inthrone"
