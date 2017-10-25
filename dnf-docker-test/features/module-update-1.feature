Feature: Updating module profiles

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: I can update a module profile to a newer version
      Given I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module install -y ModuleA:f26:1/client"
       When I successfully run "dnf module update --assumeyes ModuleA"
