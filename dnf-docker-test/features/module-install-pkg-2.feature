Feature: Installing package from module - error handling

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityY"
        And I successfully run "dnf makecache"

  Scenario: I cannot install a specific package from a disabled module when default stream is not defined
       When I save rpmdb
       When I run "dnf install -y TestY"
       Then rpmdb does not change
        And the command stderr should match regexp "Error: Unable to find a match"
        And the command exit code is 1

  @setup
  Scenario: configure default stream for next scenarios
      Given a file "/etc/dnf/modules.defaults.d/ModuleY.yaml" with
        """
         document: modulemd-defaults
         version: 1
         data:
           module: ModuleY
           stream: f26
           profiles:
             f26: [default]
        """
       When I enable repository "ursineY"

  Scenario: module content masks ursine content - disabled module
        When I run "dnf install TestY-2-1 -y"
        Then the command exit code is 1
         And the command stderr should match regexp "Error: Unable to find a match"
         And the command stdout should match regexp "No match for argument: TestY-2-1"

  Scenario: module content masks ursine content - enabled module
       When I successfully run "dnf module enable ModuleY:f27 -y"
        And I run "dnf install TestY-2-1 -y"
       Then the command exit code is 1
        And the command stderr should match regexp "Error: Unable to find a match"
        And the command stdout should match regexp "No match for argument: TestY-2-1"
