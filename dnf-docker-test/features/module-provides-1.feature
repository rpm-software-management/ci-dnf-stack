Feature: Module provides command

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  # bz1623866
  # bz1629667
  @xfail @bz1629667
  Scenario: I can get list of all modules providing specific package
       When I successfully run "dnf module provides TestH"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           TestH-1-1.modB.noarch
           Module   : ModuleB:f26:1
           Profiles : default
           Repo     : modularityABDE
           Summary  : Module ModuleB summary

           TestH-2-1.modB.noarch
           Module   : ModuleB:f27:1
           Profiles : default
           Repo     : modularityABDE
           Summary  : Module ModuleB summary
           """

  @xfail @bz1623866
  Scenario: I can get list of enabled modules providing specific package
       When I successfully run "dnf module enable ModuleB:f26 -y"
        And I successfully run "dnf module provides TestH"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           TestH-1-1.modB.noarch
           Module   : ModuleB:f26:1
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
