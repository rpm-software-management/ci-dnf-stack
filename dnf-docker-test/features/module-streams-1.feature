Feature: Show enabled streams information

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"
        And I successfully run "dnf module enable ModuleA:f26 -y"
        And I successfully run "dnf module enable ModuleB:f27 -y"

  Scenario: I can get list of enabled module streams
       When I successfully run "dnf module streams"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleA +f26 \[e\] +client, default, devel, minimal, server.*Module +ModuleA summar
           ?\.\.
           ModuleB +f27 \[e\] +default +Module +ModuleB summar
           ?\.\.
           
           Hint:
           """

  Scenario: I can limit the listing to specific module
       When I successfully run "dnf module streams ModuleB"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name +Stream +Profiles +Summary
           ModuleB +f27 \[e\] +default +Module +ModuleB summary
           
           Hint:
           """
