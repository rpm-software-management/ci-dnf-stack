Feature: Enabling module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: I can enable a module when specifying stream
       When I successfully run "dnf module enable ModuleA:f26"
#TODO: add a check that the module is really enabled

  Scenario: I can enable a module when specifying both stream and corrent version
       When I successfully run "dnf module enable ModuleB:f26:1"
#TODO: add a check that the module is really enabled

  Scenario: Enabling of an already enabled module would pass
       When I successfully run "dnf module enable ModuleA:f26"

  Scenario: I can enable a different stream of an already enabled module
       When I successfully run "dnf module enable ModuleA:f27 --assumeyes"
