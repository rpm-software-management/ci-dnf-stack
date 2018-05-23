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
