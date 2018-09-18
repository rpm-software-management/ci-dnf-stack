Feature: Modular content is preferred over ursine content regardless on NVRs

  @setup
  Scenario: test setup
      Given I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityY"
        And I enable repository "ursineY"
        And I successfully run "dnf makecache"
