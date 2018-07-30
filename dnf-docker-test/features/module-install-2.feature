Feature: Installing module profiles with dependencies

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-4.setup"
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  Scenario: Installing a module and its dependencies
       When I save rpmdb
        And I successfully run "dnf module install --assumeyes ModuleM:f26"
       Then a module ModuleM config file should contain
         | Key      | Value |
         | enabled  | True  |
         | stream   | f26   |
         | version  | 1     |
        And a module ModuleMX config file should contain
         | Key      | Value |
         | enabled  | True  |
         | stream   | f26   |
         # version  | 1     | # note: skip version check since module is only enabled, not installed
        And rpmdb changes are
         | State     | Packages                                                             |
         | installed | TestMA/1-1.modM, TestMB/1-1.modM, TestMBX/1-1.modM, TestMX/1-1.modMX |

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581160
  @xfail
  Scenario: Installing module and its dependencies in a different stream
      Given I successfully run "dnf module install --assumeyes ModuleM:f26"
       When I save rpmdb
        And I successfully run "dnf module install --assumeyes ModuleM:f27"
       Then a module ModuleM config file should contain
         | Key      | Value |
         | enabled  | True  |
         | stream   | f27   |
         | version  | 1     |
        And a module ModuleMX config file should contain
         | Key      | Value |
         | enabled  | 0     |
         | stream   | f26   |
         # version  | -1    | # version irrelevant for disabled module
        And a module ModuleMY config file should contain
         | Key      | Value |
         | enabled  | True  |
         | stream   | f27   |
         # version  | 1     | # note: skip version check since module is only enabled, not installed
        And rpmdb changes are
         | State     | Packages                                            |
         | unchanged | TestMA/1-1.modM                                     |
         | installed | TestMC/1-1.modM, TestMCY/1-1.modM, TestMY/1-1.modMY |
         | removed   | TestMB/1-1.modM, TestMBX/1-1.modM, TestMX/1-1.modMX |

