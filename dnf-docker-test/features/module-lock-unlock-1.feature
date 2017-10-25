Feature: Locking a module profile (positive locking scenarios)

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: I can lock an enabled module:stream at a current version when there is an installed profile present
      Given I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module install -y ModuleA:f26:1/client"
       When I successfully run "dnf module lock ModuleA"
# TODO: add test to check the version lock
      Given I successfully run "dnf module unlock ModuleA"
       When I successfully run "dnf module lock ModuleA:f26"
# TODO: add test to check the version lock
      Given I successfully run "dnf module unlock ModuleA"
       When I successfully run "dnf module lock ModuleA:f26:1"
# TODO: add test to check the version lock

  Scenario: I can lock an already locked module
       When I successfully run "dnf module lock ModuleA"
# TODO: add test to check the version lock
       When I successfully run "dnf module lock ModuleA:f26"
# TODO: add test to check the version lock
       When I successfully run "dnf module lock ModuleA:f26:1"
# TODO: add test to check the version lock

  Scenario: I can lock an enabled module:stream at the currently latest available version when there no installed profile
      Given I successfully run "dnf module enable ModuleB:f26"
       When I successfully run "dnf module lock ModuleB"
# TODO: add test to check the version lock
      Given I successfully run "dnf module unlock ModuleB"
       When I successfully run "dnf module lock ModuleB:f26"
# TODO: add test to check the version lock

  Scenario: I can lock an enabled module:stream at any available version when there no installed profile
      Given I successfully run "dnf module unlock ModuleB"
       When I successfully run "dnf module lock ModuleB:f26:1"
# TODO: add test to check the version lock
