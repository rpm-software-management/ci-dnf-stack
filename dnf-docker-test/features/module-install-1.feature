Feature: Installing module profiles

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
        And I run steps from file "modularity-repo-2.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

#  Scenario: I can install a module profile without specifying a profile
#      Given I successfully run "dnf module enable ModuleB:f26"
#       When I successfully run "dnf module install ModuleB"

  Scenario: I can install a specific module profile
      Given I successfully run "dnf module enable ModuleA:f26"
       When I successfully run "dnf module install -y ModuleA/minimal"

  Scenario: I can install additional module profile
       When I successfully run "dnf module install --assumeyes ModuleA/client"
