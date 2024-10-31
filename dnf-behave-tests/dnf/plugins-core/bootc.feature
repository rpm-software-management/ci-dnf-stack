Feature: Bootc plugin

@bootc
Scenario: Call bootc status
  Given I do not disable plugins
   When I execute dnf with args "bootc status"
   Then the exit code is 0
    And stdout contains "State: idle"
