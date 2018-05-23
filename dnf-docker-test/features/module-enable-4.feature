Feature: Enabling module stream with dependencies

  @setup
  Scenario: Testing module dependency handling
      Given I run steps from file "modularity-repo-4.setup"
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  Scenario: Enabling a module and its dependencies
       When I save rpmdb
        And I successfully run "dnf module enable ModuleM:f26 --assumeyes"
       Then a module ModuleM config file should contain
          | Key      | Value |
          | enabled  | 1     |
          | stream   | f26   |
          | version  | -1    |
        And a module ModuleMX config file should contain
          | Key      | Value |
          | enabled  | 1     |
          | stream   | f26   |
          | version  | -1    |
        And rpmdb does not change

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581160
  @xfail
  Scenario: Enabling module and its dependencies in a different stream
      Given I successfully run "dnf module enable ModuleM:f26 --assumeyes"
       When I save rpmdb
        And I successfully run "dnf module enable ModuleM:f27 --assumeyes"
       Then a module ModuleM config file should contain
          | Key      | Value |
          | enabled  | 1     |
          | stream   | f27   |
          | version  | -1    |
        And a module ModuleMX config file should contain
          | Key      | Value |
          | enabled  | 0     |
          | stream   | f26   |
          | version  | -1    |
        And a module ModuleMY config file should contain
          | Key      | Value |
          | enabled  | 1     |
          | stream   | f27   |
          | version  | -1    |
        And rpmdb does not change

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581160
  @xfail
  Scenario: Enabling different stream of installed module with its deps
      Given I successfully run "dnf module enable ModuleM:f26 --assumeyes"
        And I successfully run "dnf module install ModuleM:f26 --assumeyes"
       When I save rpmdb
        And I successfully run "dnf module enable ModuleM:f27 --assumeyes"
       Then a module ModuleM config file should contain
          | Key     | Value |
          | enabled | 1     |
          | stream  | f27   |
          | version | -1    |
        And a module ModuleMX config file should contain
          | Key     | Value |
          | enabled | 0     |
          | stream  | f26   |
          | version | -1    |
        And a module ModuleMY config file should contain
          | Key     | Value |
          | enabled | 1     |
          | stream  | f27   |
          | version | -1    |
        And rpmdb changes are
          | State   | Packages                                                            |
          | removed | TestMA/1-1.modM, TestMB/1-1.modM, TestMBX/1-1.modM, TestMX/1-1.modM |

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581160
  @xfail
  Scenario: Enabling different stream of installed module with chain deps
      Given I successfully run "dnf module enable ModuleMZ:f26 --assumeyes"
        And I successfully run "dnf module install ModuleMZ:f26 --assumeyes"
       When I save rpmdb
        And I successfully run "dnf module enable ModuleMZ:f27 --assumeyes"
       Then a module ModuleM config file should contain
          | Key     | Value |
          | enabled | 1     |
          | stream  | f27   |
          | version | -1    |
        And a module ModuleMX config file should contain
          | Key     | Value |
          | enabled | 0     |
          | stream  | f26   |
          | version | -1    |
        And a module ModuleMY config file should contain
          | Key     | Value |
          | enabled | 1     |
          | stream  | f27   |
          | version | -1    |
        And a module ModuleMZ config file should contain
          | Key     | Value |
          | enabled | 1     |
          | stream  | f27   |
          | version | -1    |
        And rpmdb changes are
          | State   | Packages                                                                             |
          | removed | TestMA/1-1.modM, TestMB/1-1.modM, TestMBX/1-1.modM, TestMX/1-1.modM, TestMZ/1-1.modM |
