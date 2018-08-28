Feature: Installing module profiles -- error handling

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-2.setup"
        And repository "nonmodularX" with packages
         | Package    | Tag     | Value |
         | nonX/TestX | Version | 1     |
         |            | Release | 1     |
       When I enable repository "modularityX"
        And I successfully run "dnf makecache"

  Scenario: A proper error message is displayed when I try to install a non-existant module
       When I run "dnf module install NoSuchModule"
       Then the command exit code is 1
        And the command stderr should match exactly
            """
            Error: No such module: NoSuchModule

            """

  Scenario: A proper error message is displayed when I try to install a non-existant module using group syntax
       When I run "dnf install @NoSuchModule"
       Then the command exit code is 1
        And the command stderr should match regexp "Module or Group 'NoSuchModule' does not exist"

  Scenario: I cannot install an RPM with same name as an RPM that belongs to enabled MODULE:STREAM
       When I enable repository "nonmodularX"
        And I successfully run "dnf module enable ModuleX:f26 -y"
        And I run "dnf install -y TestX-1-1.nonX"
       Then the command exit code is 1
        And the command stdout should match regexp "No match for argument: TestX-1-1.nonX"
