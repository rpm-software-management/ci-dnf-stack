Feature: Lazy enabling module stream with dependencies

  @setup
  Scenario: Testing module dependency handling
      Given I run steps from file "modularity-repo-4.setup"
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1622566
  Scenario: Lazy enabling a module and its dependencies when installing
       When I save rpmdb
        And I successfully run "dnf module enable ModuleM:f26 --assumeyes"
       Then a module ModuleM config file should contain
          | Key      | Value   |
          | state    | enabled |
          | stream   | f26     |
        And a file "/etc/dnf/modules.d/ModuleMX.module" does not exist
        And rpmdb does not change
       When I save rpmdb
        And I successfully run "dnf module install ModuleM/default -y"
       Then a module ModuleMX config file should contain
          | Key      | Value   |
          | state    | enabled |
          | stream   | f26     |
        And rpmdb changes are
         | State     | Packages |
         | installed | TestMA/1-1.modM, TestMB/1-1.modM, TestMBX/1-1.modM, TestMX/1-1.modMX |
