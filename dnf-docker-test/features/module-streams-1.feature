Feature: Show enabled streams information

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"
        And I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module enable ModuleB:f27"

  Scenario: I can get list of enabled module streams
       When I successfully run "dnf module streams"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name *Stream *Version *Profiles
           ModuleA *f26 \[e\] *1 *client, default, ...
           ModuleA *f26 \[e\] *2 *client, default, ...
           ModuleB *f27 \[e\] *1 *default
           
           Hint:
           """

  Scenario: I can limit the listing to specific module
       When I successfully run "dnf module streams ModuleB"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           modularityABDE
           Name *Stream *Version *Profiles
           ModuleB *f27 \[e\] *1 *default
           
           Hint:
           """
