Feature: Installing package from module

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityY"
        And I successfully run "dnf module enable ModuleY:f26"
        And I successfully run "dnf makecache"

  Scenario: I can install a specific package from a module
       When I save rpmdb
       When I successfully run "dnf install -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestY/1-1.modY |
        And a module ModuleY config file should contain
          | Key     | Value |
          | version | -1    |

  Scenario: I can install a package from modular repo not belonging to a module
       When I save rpmdb
        And I successfully run "dnf install --assumeyes TestUrsine"
       Then rpmdb changes are
          | State     | Packages                        |
          | installed | TestUrsine/1-1, TestUrsine2/1-1 |
