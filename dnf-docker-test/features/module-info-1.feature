Feature: Module profile info

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf -y module enable ModuleA:f26"
        And I successfully run "dnf makecache"

  Scenario: I can get info for an enabled module profile
       When I successfully run "dnf module info ModuleA"

  Scenario: I can get info for a disabled module profile when specifying stream
       When I successfully run "dnf module info ModuleB:f26"
