Feature: Module profile removal

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf -y module enable ModuleA:f26"
        And I successfully run "dnf -y module install ModuleA/minimal"
        And I successfully run "dnf -y module install ModuleA/client"
        And I successfully run "dnf -y module install ModuleA/devel"
        And I successfully run "dnf -y module enable ModuleB:f26"
        And I successfully run "dnf -y module install ModuleB/default"
        And I successfully run "dnf makecache"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581609
  Scenario: I can remove an installed module profile specifying stream name
       When I save rpmdb
        And I successfully run "dnf module remove --assumeyes ModuleB:f26"
       Then rpmdb changes are
          | State   | Packages                       |
          | removed | TestG/1-2.modB, TestI/1-1.modB |
        And a module ModuleB config file should contain
          | Key      | Value   |
          | profiles |         |
          | state    | enabled |

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581621
  Scenario: I can remove an installed module profile
       When I save rpmdb
        And I successfully run "dnf module remove -y ModuleA/minimal"
       Then rpmdb changes are
          | State     | Packages       |
          # cannot remove TestA because it's needed by other profiles
          | unchanged | TestA/1-2.modA |
        And a module ModuleA config file should contain
          | Key      | Value               |
          # Other profiles are still installed
          | profiles | (set) client, devel |
          | state    | enabled             |

  @setup
  Scenario: Setup due to previous xfail test.. please remove when the bug above is fixed
      Given I successfully run "dnf module install -y ModuleA/minimal"
        And I successfully run "dnf module remove -y ModuleA/minimal"
        And I successfully run "dnf module install -y ModuleA/client ModuleA:f26/devel"

  Scenario: Removing of a non-installed profiles should fail
       When I save rpmdb
        And I run "dnf module remove --assumeyes ModuleA/server"
       Then the command exit code is 1
        And rpmdb does not change
        And a module ModuleA config file should contain
          | Key      | Value               |
          | profiles | (set) client, devel |
          | state    | enabled             |
        And the command stderr should match regexp "Error: Specified profile not installed for ModuleA/server"

  Scenario: I can remove multiple profiles
       When I save rpmdb
        And I successfully run "dnf module remove -y ModuleA/client ModuleA:f26/devel"
       Then rpmdb changes are
          | State   | Packages                                       |
          | removed | TestA/1-2.modA, TestB/1-1.modA, TestD/1-1.modA |
       And a module ModuleA config file should contain
          | Key      | Value   |
          | state    | enabled |
          | profiles |         |
