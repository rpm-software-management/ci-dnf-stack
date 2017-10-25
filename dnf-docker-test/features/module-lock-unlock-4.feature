Feature: Locking a module profile (positive locking scenarios)

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"
        And I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module enable ModuleB:f26"

  Scenario: I can unlock a locked module:stream:version just by referring the module name
      Given I successfully run "dnf module lock ModuleA:f26:1"
       When I successfully run "dnf module unlock ModuleA"
# TODO: add a test that a module is unlocked

  Scenario: Unlock of an already unlocked module:stream:version should pass
       When I successfully run "dnf module unlock ModuleB:f26:1"
# TODO: add a test for an error message
       When I successfully run "dnf module unlock ModuleB:f26"
# TODO: add a test for an error message
       When I successfully run "dnf module unlock ModuleB"
# TODO: add a test for an error message

  @xfail
  Scenario: Unlocking a module:stream:version not matching a locked module:stream:version should fail
      Given I successfully run "dnf module lock ModuleB:f26:1"
       When I run "dnf module unlock ModuleB:f26:2"
       Then the command exit code is 1
# TODO: add a test for an error message

  Scenario: Unlocking of an invalid module:stream:version should fail
       When I run "dnf module unlock ModuleB:f26:99"
       Then the command exit code is 1
# TODO: add a test for an error message
       When I run "dnf module unlock ModuleB:f00"
       Then the command exit code is 1
# TODO: add a test for an error message
       When I run "dnf module unlock NoSuchModule:f26"
       Then the command exit code is 1
# TODO: add a test for an error message

  Scenario: Unlocking of a disabled module should fail
       When I run "dnf module unlock ModuleE:f26:1"
       Then the command exit code is 1
# TODO: add a test for an error message
       When I run "dnf module unlock ModuleD:f26"
       Then the command exit code is 1
# TODO: add a test for an error message
