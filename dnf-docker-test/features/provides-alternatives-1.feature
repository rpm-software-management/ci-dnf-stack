Feature: Alternative packages are suggested when package is not available

  @setup
  Scenario: Testing repository
    Given repository "base" with packages
         | Package | Tag      | Value                  |
         | TestA   | Provides | alternative-for(TestC) |
         | TestB   | Provides | alternative-for(TestC) |
      When I enable repository "base"
        And I successfully run "dnf makecache"

  @bz1625586
  Scenario: Alternative package are suggested during package install
       When I run "dnf install TestC"
       Then the command should fail
        And the command stdout should match regexp "No match for argument: TestC"
        And the command stdout should match regexp "There are following alternatives for \"TestC\": TestA, TestB"
        And the command stderr should match regexp "Error: Unable to find a match"
