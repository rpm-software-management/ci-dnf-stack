Feature: Tests for report nonexisting plugin

Background: Enable builddep plugin
  Given I enable plugin "builddep"
    And I use the repository "dnf-ci-fedora"

@bz1673289 @bz1467304
Scenario: Report nonexisting plugin to disable
   When I execute dnf with args "repoquery empty --disableplugin=NotExisting"
   Then the exit code is 0
    And stderr contains "No matches found for the following disable plugin patterns: NotExisting"

@bz1673289 @bz1467304
Scenario: Report nonexisting plugin to enable
   When I execute dnf with args "repoquery empty --enableplugin=NotExisting"
   Then the exit code is 0
    And stderr contains "No matches found for the following enable plugin patterns: NotExisting"

