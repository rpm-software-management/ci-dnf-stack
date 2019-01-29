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
