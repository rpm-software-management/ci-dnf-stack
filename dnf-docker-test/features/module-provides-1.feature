Feature: Module provides command

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: I can get list of modules providing specific package
       When I successfully run "dnf module provides TestH"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           TestH-0:1-1.modB.noarch
           Module   : ModuleB:f26:1
           Profiles : default
           Repo     : modularityABDE
           Summary  : Module ModuleB summary

           TestH-0:2-1.modB.noarch
           Module   : ModuleB:f27:1
           Profiles : default
           Repo     : modularityABDE
           Summary  : Module ModuleB summary
           """

  Scenario: There is not output when no module provides the package
       When I successfully run "dnf module provides NoSuchPackage"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check

           """

  Scenario: An error is printed when no arguments are provided
       When I run "dnf module provides"
       Then the command exit code is 1
        And the command stderr should match exactly
           """
           Error: dnf module provides: too few arguments
           
           """
