Feature: Show modular errors

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"
        And I successfully run "dnf module enable ModuleE:f26 -y"
        And I successfully run "dnf module disable ModuleD --skip-broken -y"

  @bz1688823
  Scenario: I can install a module in presence of a modular error
       When I successfully run "dnf install @ModuleB:f26 -y"
       Then a module ModuleB config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | f26     |
       And the command stdout should match regexp "Enabling module streams:"
       And the command stdout should match regexp "ModuleB +f26"
       And the command stderr should not match regexp "Traceback"
