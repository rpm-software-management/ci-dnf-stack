Feature: Tests for debuginfo symbols

@bz1585137
Scenario: debuginfo-install reports an error when debuginfo is not found
Given I use the repository "dnf-ci-fedora"
  And I enable plugin "debuginfo-install"
 When I execute dnf with args "debuginfo-install non-existent-package"
 Then the exit code is 1
  And stdout contains "No match for argument: non-existent-package"
  And stdout contains "No debuginfo packages available to install"
  And stderr contains "Error: Unable to find a match"

