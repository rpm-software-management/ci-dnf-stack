Feature: Enabling module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: I can enable a module when specifying stream
       When I successfully run "dnf module enable ModuleA:f26"

  Scenario: I can't enable a module without specifying a stream
       When I run "dnf module enable ModuleB"
       Then the command exit code is 1
