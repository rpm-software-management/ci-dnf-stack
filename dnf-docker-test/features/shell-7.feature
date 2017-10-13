Feature: Reinstall in dnf shell
 repo base: TestA-1 TestB-1
 repo ext1: TestA-2 TestB-2

  @setup
  Scenario: Setup (install TestA-1 TestB-1)
      Given repository "base" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 1         |
         | TestB        | Version  | 1         |
        And repository "ext1" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 2         |
         | TestB        | Version  | 2         |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestB"
        And I enable repository "ext1"
       Then rpmdb changes are
         | State     | Packages         |
         | installed | TestA/1, TestB/1 |

  Scenario: reinstall nonexistentpkg
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "reinstall nonexistentpkg"
     Then the command stdout should match regexp "No match for argument"
      And the command stdout should match regexp "No packages marked for reinstall"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: reinstall TestA (when relevant repo is disabled)
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "repo disable base"
     When I run dnf shell command "reinstall TestA"
     Then the command stdout should match regexp "Installed package.*not available"
      And the command stdout should match regexp "No packages marked for reinstall"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: reinstall TestA (when relevant repo is enabled)
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "repo enable base"
     When I run dnf shell command "reinstall TestA"
     When I run dnf shell command "run"
     Then the command stdout should match regexp "Reinstalled"
      And the command stdout should match regexp "TestA.*1-1"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: reinstall Test\*
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "reinstall Test\*"
     When I run dnf shell command "run"
     Then the command stdout should match regexp "Reinstalled"
      And the command stdout should match regexp "TestA.*1-1"
      And the command stdout should match regexp "TestB.*1-1"
     When I run dnf shell command "exit"
     Then the command should pass
