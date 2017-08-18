Feature: Test for dnf repoquery, options --all, --installed, --available, --upgrades, --recent, --extras, --repo 
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
         | TestA        | Version  | 2         |
         | TestB        | Version  | 2         |

  # --extras: installed pkgs, not from known repos
  Scenario: dnf repoquery --extras (when there are such pkgs)
       When I successfully run "rpm -i TestA-1*.rpm" in repository "base"
        And I successfully run "dnf repoquery --extras"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should not match regexp "TestB"
        And the command stdout should not match regexp "XTest"

  Scenario: dnf repoquery --extras XTest (when there's no such extra pkg installed)
       When I run "dnf repoquery --extras XTest"
       Then the command stdout should not match regexp "XTest"
        And the command stdout should not match regexp "TestA"
        And the command stdout should not match regexp "TestB"

  Scenario: dnf repoquery --available Test\* (when there are no such pkgs)
       When I successfully run "dnf repoquery --available Test\*"
       Then the command stdout should not match regexp "Test"

  Scenario: dnf repoquery --available --repo base --repo ext TestB\* (when there are such pkgs in listed repos)
       When I successfully run "dnf repoquery --available --repo base --repo ext TestB\*"
       Then the command stdout should match regexp "TestB.*1-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should not match regexp "TestA"
        And the command stdout should not match regexp "XTest"

  Scenario: dnf repoquery --available Test\* (when there are such pkgs)
       When I enable repository "ext"
        And I successfully run "dnf repoquery --available Test\*"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should not match regexp "TestA.*1-1"
        And the command stdout should not match regexp "TestB.*1-1"
        And the command stdout should not match regexp "XTest"

  Scenario: dnf repoquery --upgrades (when there are such pkgs)
       When I successfully run "dnf repoquery --upgrades"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should not match regexp "TestB"
        And the command stdout should not match regexp "XTest"

  Scenario: dnf repoquery --upgrades Test\* (when there are no such pkgs)
       When I disable repository "ext"
        And I successfully run "dnf repoquery --upgrades Test\*"
       Then the command stdout should not match regexp "TestA.*2-1"
        And the command stdout should not match regexp "TestB"
        And the command stdout should not match regexp "XTest"

  Scenario: dnf repoquery --upgrades --repo ext (when there are such pkgs in listed repos)
       When I successfully run "dnf repoquery --upgrades --repo ext"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should not match regexp "TestB"
        And the command stdout should not match regexp "XTest"

  Scenario: dnf repoquery --installed XTest\* (when there are no such pkgs)
       When I successfully run "dnf repoquery --installed XTest\*"
       Then the command stdout should not match regexp "Test"

  Scenario: dnf repoquery --installed Test\* (when there are such pkgs)
       When I enable repository "ext"
        And I successfully run "dnf -y upgrade TestA"
        And I successfully run "dnf repoquery --installed Test\*"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should not match regexp "TestB"
        And the command stdout should not match regexp "XTest"

  Scenario: dnf repoquery --installed TestA XTest (when TestA is installed and XTest not)
       When I successfully run "dnf repoquery --installed TestA XTest"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should not match regexp "XTest"
        And the command stdout should not match regexp "TestB"

  # --recent: recently edited pkgs, all pkgs in ext and base repos are supposed
  #           to be recently edited
  Scenario: dnf repoquery --recent TestC (when there's no such pkg)
       When I successfully run "dnf repoquery --recent TestC"
       Then the command stdout should not match regexp "Test"

  Scenario: dnf repoquery --recent Test\* (when there are such pkgs)
       When I successfully run "dnf repoquery --recent Test\*"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should not match regexp "XTest"
        And the command stdout should not match regexp "Test.*1-1"

  Scenario: dnf repoquery --recent --installed Test\* (when there are such pkgs installed)
       When I successfully run "dnf repoquery --installed --recent Test\*"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should not match regexp "TestB"
        And the command stdout should not match regexp "XTest"
        And the command stdout should not match regexp "Test.*1-1"

  Scenario: dnf repoquery --recent --repo base Test\* (when there are such pkgs in listed repo)
       When I successfully run "dnf repoquery --recent --repo base Test\*"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "TestB.*1-1"
        And the command stdout should not match regexp "XTest"
        And the command stdout should not match regexp "Test.*2-1"

  Scenario: dnf repoquery --all TestC (when there's no such pkg)
       When I successfully run "dnf repoquery --all TestC"
       Then the command stdout should not match regexp "Test"

  Scenario: dnf repoquery --all Test\* (when there are such pkgs)
       When I successfully run "dnf repoquery --all Test\*"
       Then the command stdout should match regexp "TestA.*2-1"
        And the command stdout should match regexp "TestB.*2-1"
        And the command stdout should not match regexp "XTest"
        And the command stdout should not match regexp "Test.*1-1"

  Scenario: dnf repoquery --all --repo base Test\* (when there are such pkgs in listed repo)
       When I successfully run "dnf repoquery --all --repo base Test\*"
       Then the command stdout should match regexp "TestA.*1-1"
        And the command stdout should match regexp "TestB.*1-1"
        And the command stdout should not match regexp "XTest"
        And the command stdout should not match regexp "Test.*2-1"
