Feature: Testing specific dnf shell text output

  @setup
  Scenario: Preparing a test repository with package group defined
      Given repository "TestRepo" with packages
           | Package | Tag | Value |
           | TestA   |     |       |
           | TestB   |     |       |
        And package groups defined in repository "TestRepo"
           | Group     | Tag         | Value   |
           | TestGroup | mandatory   | TestA   |
           |           | default     | TestB   |

  Scenario: Enabling a non-existent repository
      Given I have dnf shell session opened with parameters "-y"
       When I run dnf shell command "repository enable NoSuchRepo"
       Then the command stdout should match regexp "Error: Unknown repo: 'NoSuchRepo'"

  Scenario: Disabling a non-existent repository
      Given I have dnf shell session opened with parameters "-y"
       When I run dnf shell command "repository disable NoSuchRepo"
       Then the command stdout should match regexp "Error: Unknown repo: 'NoSuchRepo'"

  Scenario: Installing a package with no repos enabled
      Given I have dnf shell session opened with parameters "-y"
       When I run dnf shell command "install NoSuchPackage"
       Then the command stdout should match regexp "Error: There are no enabled repos\."

  Scenario: Installing a non-existent package
      Given I have dnf shell session opened with parameters "-y"
       When I run dnf shell command "repository enable TestRepo"
        And I run dnf shell command "install NoSuchPackage"
       Then the command stdout should match regexp "No package NoSuchPackage available\."

  Scenario: Removing a non-existent package
      Given I have dnf shell session opened with parameters "-y"
       When I run dnf shell command "remove NoSuchPackage"
       Then the command stdout should match regexp "No match for argument: NoSuchPackage"

  Scenario: Installing a non-existent package group
      Given I have dnf shell session opened with parameters "-y"
       When I run dnf shell command "repository enable TestRepo"
        And I run dnf shell command "group install NoSuchGroup"
       Then the command stdout should match regexp "Warning: Group 'NoSuchGroup' does not exist\."

  Scenario: Removing a non-existent package group
      Given I have dnf shell session opened with parameters "-y"
       When I run dnf shell command "repository enable TestRepo"
        And I run dnf shell command "group remove NoSuchGroup"
       Then the command stdout should match regexp "Warning: Group 'NoSuchGroup' is not installed\."

  Scenario: Listing available commands when help command is issued
      Given I have dnf shell session opened with parameters "-y"
       When I run dnf shell command "help"
       Then the command stdout should match regexp "usage: dnf \[options\] COMMAND"
        And the command stdout should match regexp "List of Main Commands:"
        And the command stdout should match regexp "List of Plugin Commands:"
        And the command stdout should match regexp "Optional arguments:"
        And the command stdout should match regexp "Shell specific arguments:"
