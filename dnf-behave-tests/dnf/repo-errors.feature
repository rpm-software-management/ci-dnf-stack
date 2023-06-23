@dnf5
Feature: Test error handling related to repositories

Scenario: Invalid character in ID in --repofrompath
 When I execute dnf with args "--repofrompath=a/b,URL list"
 Then the exit code is 1
  And stderr is
      """
      Invalid repository id "a/b": unexpected character '/'
      """
