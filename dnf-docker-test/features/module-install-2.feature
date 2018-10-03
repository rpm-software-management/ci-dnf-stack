Feature: Installing module profiles with dependencies

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-4.setup"
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  Scenario: Installing a module and its dependencies
       When I save rpmdb
        And I successfully run "dnf module install --assumeyes ModuleM:f26/default"
       Then a module ModuleM config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | f26     |
        And a module ModuleMX config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | f26     |
        And rpmdb changes are
         | State     | Packages                                                             |
         | installed | TestMA/1-1.modM, TestMB/1-1.modM, TestMBX/1-1.modM, TestMX/1-1.modMX |

