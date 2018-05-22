Feature: Enabling module stream with dependencies

  @setup
  Scenario: Testing module dependency handling
      Given I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityY"
        And I successfully run "dnf makecache"

  Scenario: Enabling a module and its dependencies
       When I save rpmdb
        And I successfully run "dnf module enable ModuleW:f26 --assumeyes"
       Then a module ModuleW config file should contain
          | Key      | Value |
          | enabled  | 1     |
          | stream   | f26   |
          | version  | -1    |
        And a module ModuleY config file should contain
          | Key      | Value |
          | enabled  | 1     |
          | stream   | f26   |
          | version  | -1    |
        And rpmdb does not change

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581160
  @xfail
  Scenario: Enabling module and its dependencies in a different stream
      Given I successfully run "dnf module enable ModuleW:f26 --assumeyes"
       When I save rpmdb
        And I successfully run "dnf module enable ModuleW:f27 --assumeyes"
       Then a module ModuleW config file should contain
          | Key      | Value |
          | enabled  | 1     |
          | stream   | f27   |
          | version  | -1    |
        And a module ModuleY config file should contain
          | Key      | Value |
          | enabled  | 0     |
          | stream   | f26   |
          | version  | -1    |
        And a module ModuleZ config file should contain
          | Key      | Value |
          | enabled  | 1     |
          | stream   | f27   |
          | version  | -1    |
        And rpmdb does not change

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581160
  @xfail
  Scenario: Enabling different stream of installed module with its deps
      Given I successfully run "dnf module enable ModuleW:f26 --assumeyes"
        And I successfully run "dnf module install ModuleW:f26 --assumeyes"
       When I save rpmdb
        And I successfully run "dnf module enable ModuleW:f27 --assumeyes"
       Then a module ModuleW config file should contain
          | Key     | Value |
          | enabled | 1     |
          | stream  | f27   |
          | version | 1     |
        And a module ModuleY config file should contain
          | Key     | Value |
          | enabled | 0     |
          | stream  | f26   |
          | version | -1    |
        And a module ModuleZ config file should contain
          | Key     | Value |
          | enabled | 1     |
          | stream  | f27   |
          | version | -1    |
        And rpmdb changes are
          | State     | Packages                           |
          | removed   | TestM-0:1-1.modD, TestP-0:1-1.modE |
