Feature: Module info --profile command

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: I can get the info about content of existing module streams
       When I successfully run "dnf module info --profile ModuleA"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Name +: ModuleA:f26:1::noarch
           client +: Test.*
           ? +: Test.*
           server +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*

           Name +: ModuleA:f26:2::
           client +: Test.*
           ? +: Test.*
           server +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*
 
           Name +: ModuleA:f27:1::
           client +: Test.*
           ? +: Test.*
           server +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*
           """

  Scenario: Profile specification is ignored by dnf module info --profile
       When I successfully run "dnf module info --profile ModuleA/client"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Ignoring unnecessary profile: 'ModuleA/client'
           Name +: ModuleA:f26:1::noarch
           client +: Test.*
           ? +: Test.*
           server +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*

           Name +: ModuleA:f26:2::
           client +: Test.*
           ? +: Test.*
           server +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*
 
           Name +: ModuleA:f27:1::
           client +: Test.*
           ? +: Test.*
           server +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*
           """

  Scenario: I can get the info about contents of more than one module profile streams
       When I successfully run "dnf module info --profile ModuleD:f26 ModuleE:f26"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check
           Name +: ModuleD:f26:1
           default +: TestM.*

           Name +: ModuleE:f26:1
           default +: TestP.*
           """

  Scenario: "dnf module profile" without any additional arguments should raise an error
       When I run "dnf module info --profile"
       Then the command exit code is 1
        And the command stderr should match exactly
           """
           Error: dnf module info: too few arguments

           """
