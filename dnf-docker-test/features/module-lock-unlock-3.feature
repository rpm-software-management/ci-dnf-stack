Feature: Locking a module profile (positive locking scenarios)

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"
        And I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module install -y ModuleA:f26:1/client"
        And I successfully run "dnf module enable ModuleE:f26"

  Scenario: Locking a module:stream:version not matching an already locked module:stream:version should fail
      Given I successfully run "dnf module lock ModuleA:f26:1"
       When I run "dnf module lock ModuleA:f26:2"
       Then the command exit code is 1
# TODO: add a test for an error message

  Scenario: Locking a module:stream:version not matching an installed and unlocked module:stream:version should fail
      Given I successfully run "dnf module unlock ModuleA:f26"
       When I run "dnf module lock ModuleA:f26:2"
       Then the command exit code is 1
# TODO: add a test for an error message

  Scenario: Locking of an invalid module:stream:version should fail
       When I run "dnf module lock ModuleA:f00"
       Then the command exit code is 1
# TODO: add a test for an error message
       When I run "dnf module lock NoSuchModule:f26"
       Then the command exit code is 1
# TODO: add a test for an error message

  Scenario: Locking of a disabled module:stream should fail
       When I run "dnf module lock ModuleB:f26"
       Then the command exit code is 1
# TODO: add a test for an error message

  Scenario: Disabling of a locked module:stream:version should fail
        And I successfully run "dnf module lock ModuleE:f26:1"
       When I run "dnf module disable ModuleE"
       Then the command exit code is 1
# TODO: add a test for an error message
