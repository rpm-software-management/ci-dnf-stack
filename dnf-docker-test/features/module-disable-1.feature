Feature: Disabling module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf -y module enable ModuleA:f26"
        And I successfully run "dnf -y module install ModuleA/client"
        And I successfully run "dnf -y module enable ModuleB:f26"
        And I successfully run "dnf makecache"

  Scenario: I can disable an enabled module stream
       When I successfully run "dnf module disable ModuleB"

  Scenario: I can disable an enabled module stream with an installed profile
       When I successfully run "dnf module disable ModuleA"
