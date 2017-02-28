Feature: Test for dnf list (including all documented suboptions and yum compatibility)
 repo base: TestA-1 TestB-1
 repo ext: XTest-2 TestA-2 TestB-2

  @setup
  Scenario: Setup (create test repos)
      Given repository "base" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 1         |
         | TestB        | Version  | 1         |
        And repository "ext" with packages
         | Package      | Tag      | Value     |
         | XTest        | Version  | 2         |
         |              | Obsoletes| TestB     |
         | TestA        | Version  | 2         |
         | TestB        | Version  | 2         |

  Scenario: dnf list nonexistentpkg
       When I run "dnf list nonexistentpkg"
       Then the command exit code is 1
        And the command stderr should match regexp "No matching Packages"

  Scenario: dnf list extras (installed pkgs, not from known repos)
       When I successfully run "rpm -i TestA-1*.rpm" in repository "base"
        And I successfully run "dnf list extras"
       Then the command stdout should match regexp "TestA.*1-1"

  Scenario: dnf list --extras (installed pkgs, not from known repos)
       When I successfully run "dnf list --extras"
       Then the command stdout should match regexp "TestA.*1-1"

  Scenario: dnf list TestA (when TestA is installed)
       When I successfully run "dnf list TestA"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should not match regexp "Available Packages"

  Scenario: dnf list TestB (when TestB is not installed but it is available)
       When I enable repository "base"
        And I successfully run "dnf list TestB"
       Then the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Available Packages"
        And the command stdout should not match regexp "Installed Packages"

  Scenario: dnf list installed TestA (when TestA is installed)
       When I successfully run "dnf list installed TestA"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should not match regexp "Available Packages"

  Scenario: dnf list --installed TestA (when TestA is installed)
       When I successfully run "dnf list --installed TestA"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should not match regexp "Available Packages"

  Scenario: dnf list available TestB (when TestB is available)
       When I successfully run "dnf list available TestB"
       Then the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Available Packages"
        And the command stdout should not match regexp "Installed Packages"

  Scenario: dnf list --available TestB (when TestB is available)
       When I successfully run "dnf list --available TestB"
       Then the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Available Packages"
        And the command stdout should not match regexp "Installed Packages"

  Scenario: dnf list TestB TestA (when TestB is not installed)
       When I successfully run "dnf list TestB TestA"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Available Packages"

  Scenario: dnf list installed TestB TestA (when TestB is not installed)
       When I successfully run "dnf list installed TestB TestA"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should not match regexp "TestB"
        And the command stdout should not match regexp "Available Packages"

  Scenario: dnf list available TestB TestA (when TestB is available)
       When I successfully run "dnf list available TestB TestA"
       Then the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Available Packages"
        And the command stdout should not match regexp "TestA"
        And the command stdout should not match regexp "Installed Packages"

  Scenario: dnf list TestA TestB (when both pkgs are installed)
       When I successfully run "dnf -y install TestB"
        And I successfully run "dnf list TestA TestB"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should not match regexp "Available Packages"

  Scenario: dnf list installed TestA TestB (when both pkgs are installed)
       When I successfully run "dnf list installed TestA TestB"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should not match regexp "Available Packages"

  Scenario: dnf list available TestA TestB (when both pkgs are installed)
       When I run "dnf list available TestA TestB"
       Then the command exit code is 1
        And the command stderr should match regexp "No matching Packages"

  Scenario: dnf list Test\* 
       When I enable repository "ext"
       When I successfully run "dnf list Test\*"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should not match regexp "XTest"

  Scenario: dnf list upgrades
       When I successfully run "dnf list upgrades"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should match regexp "Upgraded Packages"

  Scenario: dnf list --upgrades
       When I successfully run "dnf list --upgrades"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should match regexp "Upgraded Packages"

  Scenario: dnf list updates (yum compatibility)
       When I successfully run "dnf list updates"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should match regexp "Upgraded Packages"

  Scenario: dnf list upgrades XTest (when XTest is not installed)
       When I run "dnf list upgrades XTest"
       Then the command exit code is 1
        And the command stderr should match regexp "No matching Packages"
        And the command stdout should not match regexp "Upgraded Packages"

  Scenario: dnf list obsoletes
       When I successfully run "dnf list obsoletes"
       Then the command stdout should match regexp "XTest.*2-1"
        And the command stdout should match regexp "\sTestB.*1-1"
        And the command stdout should match regexp "Obsoleting Packages"

  Scenario: dnf list --obsoletes
       When I successfully run "dnf list --obsoletes"
       Then the command stdout should match regexp "XTest.*2-1"
        And the command stdout should match regexp "\sTestB.*1-1"
        And the command stdout should match regexp "Obsoleting Packages"

  Scenario: dnf list obsoletes TestA (when TestA is not obsoleted)
       When I run "dnf list obsoletes TestA"
       Then the command exit code is 1
        And the command stderr should match regexp "No matching Packages"

  Scenario: dnf list recent (recently added are pkgs in the ext repo)
       When I successfully run "dnf list recent"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should match regexp "XTest"
        And the command stdout should match regexp "Recently Added Packages"
        And the command stdout should not match regexp "TestA.*1-1"
        And the command stdout should not match regexp "TestB.*1-1"

  Scenario: dnf list --recent (recently added are pkgs in the ext repo)
       When I successfully run "dnf list --recent"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should match regexp "XTest"
        And the command stdout should match regexp "Recently Added Packages"
        And the command stdout should not match regexp "TestA.*1-1"
        And the command stdout should not match regexp "TestB.*1-1"

  Scenario: dnf list recent TestC (when TestC is not recently added)
       When I run "dnf list recent TestC"
       Then the command exit code is 1
        And the command stderr should match regexp "No matching Packages"

  Scenario: dnf list all Test\*
       When I successfully run "dnf list all Test\*"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should match regexp "Available Packages"

  Scenario: dnf list --all Test\*
       When I successfully run "dnf list --all Test\*"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "Installed Packages"
        And the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should match regexp "Available Packages"
