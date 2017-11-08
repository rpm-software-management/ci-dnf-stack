Feature: Installing and updating disabled module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf -y module enable ModuleB:f26"

  Scenario: Disabled but installed profile should not be receiving updates
      Given I successfully run "dnf module install -y ModuleB:f26:1/default"
        And I successfully run "dnf module disable ModuleB"
       When I save rpmdb
        And I successfully run "dnf update --assumeyes"
       Then rpmdb does not change
