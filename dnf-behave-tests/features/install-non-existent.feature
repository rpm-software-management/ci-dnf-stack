Feature: Test for installation of non-existent rpm or package

@bz1578369
Scenario: Try to install a non-existent rpm
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install non-existent.rpm"
   Then the exit code is 1
    And stderr contains "Can not load RPM file"
    And stderr contains "Could not open"

Scenario: Try to install a non-existent package
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install non-existent-package"
   Then the exit code is 1
    And stdout contains "No match for argument"
    And stderr contains "Error: Unable to find a match"
