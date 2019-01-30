Feature: Use confirmation of enabling different module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"
        And I successfully run "dnf module enable -y ModuleA:f26"
        And I successfully run "dnf module enable -y ModuleB:f26"

  Scenario: Enablement of a different stream must be confirmed by the user (no confirmation)
       When I run "dnf module enable ModuleA:f27"
       Then the command exit code is 1
        And the command stdout should match regexp "Switching module streams:"
        And the command stdout should match regexp "ModuleA *f26 -> f27"
        And the command stdout should match regexp "Is this ok \[y/N\]:"
        And the command stderr should match regexp "Operation aborted."
        And a module ModuleA config file should contain
          | Key    | Value |
          | stream | f26   |

  Scenario: Enablement of a different stream can be cancelled by the user (--assumeno option)
       When I run "dnf module enable ModuleB:f27 --assumeno"
       Then the command exit code is 1
        And the command stderr should match regexp "Operation aborted."
        And a module ModuleB config file should contain
          | Key    | Value |
          | stream | f26   |

  Scenario: Enablement of a different stream must be confirmed by the user (-y option)
       When I successfully run "dnf module enable ModuleA:f27 -y"
       Then the command stdout should match regexp "Switching module streams:"
        And the command stdout should match regexp "ModuleA *f26 -> f27"
        And a module ModuleA config file should contain
          | Key    | Value |
          | stream | f27   |

  Scenario: Enablement of a different stream must be confirmed by the user (--assumeyes option)
       When I successfully run "dnf module enable ModuleB:f27 --assumeyes"
       Then the command stdout should match regexp "Switching module streams:"
        And the command stdout should match regexp "ModuleB *f26 -> f27"
        And a module ModuleB config file should contain
          | Key    | Value |
          | stream | f27   |

  @xfail @bz1579792 @bz1653623
  Scenario: Enablement of different module stream when profile installed (remove profile)
      Given I successfully run "dnf module enable ModuleA:f27 -y"
        And I successfully run "dnf module install ModuleA/minimal -y"
       When I successfully run "dnf module enable ModuleA:f26 -y"
       Then a module ModuleA config file should contain
          | Key      | Value   |
          | stream   | f26     |
          | profiles |         |
