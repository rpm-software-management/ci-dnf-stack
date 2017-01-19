Feature: Switching conflicting packages in dnf shell

  @setup
  Scenario: Preparing the test repository
    Given repository "TestRepoA" with packages
         | Package | Tag       | Value |
         | TestA   | Requires  | TestD |
         | TestB   | Provides  | TestD |
         |         | Conflicts | TestC |
         | TestC   | Provides  | TestD |
         |         | Conflicts | TestB |

  Scenario: Switching conflicting packages via install and remove
    Given I have dnf shell session opened with parameters "-y"
     When I save rpmdb
      And I run dnf shell command "repo enable TestRepoA"
      And I run dnf shell command "install TestA TestB"
      And I run dnf shell command "run"
     Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |
     When I save rpmdb
      And I run dnf shell command "remove TestB"
      And I run dnf shell command "install TestC"
      And I run dnf shell command "run"
     Then rpmdb changes are
         | State     | Packages |
         | removed   | TestB    |
         | installed | TestC    |
     When I run dnf shell command "quit"
     Then the command stdout should match exactly
          """
          Leaving Shell

          """
