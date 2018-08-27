Feature: Enabling module stream with dependencies

  @setup
  Scenario: Testing module dependency handling
      Given I run steps from file "modularity-repo-4.setup"
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1622566
  @xfail
  Scenario: Enabling a module and its dependencies
       When I save rpmdb
        And I successfully run "dnf module enable ModuleM:f26 --assumeyes"
       Then a module ModuleM config file should contain
          | Key      | Value   |
          | state    | enabled |
          | stream   | f26     |
        And a module ModuleMX config file should contain
          | Key      | Value   |
          | state    | enabled |
          | stream   | f26     |
        And rpmdb does not change

