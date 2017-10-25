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

  Scenario: I can remove an installed module profile
       When I successfully run "dnf module remove --assumeyes ModuleB"

  Scenario: I can remove an installed module profile
       When I successfully run "dnf module remove -y ModuleA/minimal"

  Scenario: Removing of a non-installed profiles should fail
       When I run "dnf module remove --assumeyes ModuleA/server"
       Then the command exit code is 1

  Scenario: I can remove multiple profiles
       When I successfully run "dnf module remove -y ModuleA/client ModuleA/devel"
