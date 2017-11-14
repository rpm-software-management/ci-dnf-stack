Feature: Disabling module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf -y module enable ModuleA:f26"
        And I successfully run "dnf -y module install ModuleA/client"
        And I successfully run "dnf -y module enable ModuleB:f26"
        And I successfully run "dnf makecache"

  Scenario: I can disable a module when specifying module name
       When I successfully run "dnf module disable ModuleB"
       Then the command stdout should match regexp "'ModuleB' is disabled"

  Scenario: I can disable a module when specifying stream
       When I successfully run "dnf module enable ModuleB:f26"
        And I successfully run "dnf module disable ModuleB:f26"
       Then the command stdout should match regexp "'ModuleB:f26' is disabled"

  Scenario: I can disable a module when specifying both stream and correct version
       When I successfully run "dnf module enable ModuleB:f26"
        And I successfully run "dnf module disable ModuleB:f26:1"
       Then the command stdout should match regexp "'ModuleB:f26:1' is disabled"

  Scenario: Disabling an already disabled module should pass
       When I successfully run "dnf module disable ModuleB:f26"
       Then the command stdout should match regexp "'ModuleB:f26' is disabled"

  Scenario: I can disable a module with installed profile when specifying module name
       When I successfully run "dnf module disable ModuleA"
       Then the command stdout should match regexp "'ModuleA' is disabled"

  Scenario: I can disable a module with installed profile when specifying stream
       When I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module disable ModuleA:f26"
       Then the command stdout should match regexp "'ModuleA:f26' is disabled"

  Scenario: I can disable a module with installed profile when specifying both stream and correct version
       When I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module disable ModuleA:f26:2"
       Then the command stdout should match regexp "'ModuleA:f26:2' is disabled"

  Scenario: I can disable a module with installed profile when specifying other valid stream
       When I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module disable ModuleA:f27"
       Then the command stdout should match regexp "'ModuleA:f27' is disabled"

  Scenario: I can disable a module with installed profile when specifying both valid stream and different existing version
       When I successfully run "dnf -y module install ModuleB:f26:1/default"
        And I successfully run "dnf module disable ModuleB:f26:2"
       Then the command stdout should match regexp "'ModuleB:f26:2' is disabled"
