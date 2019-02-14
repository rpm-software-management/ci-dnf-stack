Feature: Use confirmation of enabling different module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: Enablement of a module stream can be cancelled by the user (--assumeno option)
       When I run "dnf module enable ModuleB:f27 --assumeno"
       Then the command exit code is 1
        And the command stderr should match regexp "Operation aborted."

  Scenario: Enablement of a module stream must be confirmed by the user (-y option)
       When I successfully run "dnf module enable ModuleA:f27 -y"
       Then the command stdout should match regexp "Enabling module streams:"
        And the command stdout should match regexp "ModuleA *f27"
        And a module ModuleA config file should contain
          | Key    | Value |
          | stream | f27   |

  Scenario: Enablement of a module stream must be confirmed by the user (--assumeyes option)
       When I successfully run "dnf module enable ModuleB:f27 --assumeyes"
       Then the command stdout should match regexp "Enabling module streams:"
        And the command stdout should match regexp "ModuleB *f27"
        And a module ModuleB config file should contain
          | Key    | Value |
          | stream | f27   |
