Feature: Installing module profiles -- error handling

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
        And I run steps from file "modularity-repo-2.setup"
       When I enable repository "modularityABDE"
        And I enable repository "modularityX"
        And I successfully run "dnf makecache"

  Scenario: A proper error message is displayed when I try to install a non-existant module using group syntax
       When I run "dnf install @ModuleC"
       Then the command exit code is 1
        And the command stderr should match regexp "Module or Group 'ModuleC' does not exist"
