Feature: Module profile command

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: I can get the info about content of an enabled module stream
       When I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module profile ModuleA"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check

           Name +: ModuleA:f26:2
           client +: Test.*
           ? +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           server +: Test.*
           ? +: Test.*
           """

  Scenario: I can get the info about content of all the profiles in enabled module stream
       When I successfully run "dnf module profile ModuleA/client"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check

           Name +: ModuleA:f26:2
           client +: Test.*
           ? +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           server +: Test.*
           ? +: Test.*
           """

  Scenario: I can get the info about content of an installed module stream
       When I successfully run "dnf module install -y ModuleA/minimal"
        And I successfully run "dnf module profile ModuleA"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check

           Name +: ModuleA:f26:2
           client +: Test.*
           ? +: Test.*
           default +: Test.*
           ? +: Test.*
           ? +: Test.*
           devel +: Test.*
           minimal +: Test.*
           server +: Test.*
           ? +: Test.*
           """

  Scenario: I can get the info about content of disabled module stream
       When I successfully run "dnf module disable ModuleB:f26"
        And I successfully run "dnf module profile ModuleB:f26"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check

           Name +: ModuleB:f26:2
           default +: Test.*\.modB
            +: Test.*\.modB
           """

  Scenario: I can get the info about contents of more than one module profile streams
       When I successfully run "dnf module profile ModuleD:f26 ModuleE:f26"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check

           Name +: ModuleD:f26:1
           default +: TestM-1-1.modD

           Name +: ModuleE:f26:1
           default +: TestP-1-1.modE
           """

  Scenario: Getting info about disabled module profile without default stream defined should raise an error
       When I run "dnf module profile ModuleB"
       Then a module "ModuleB" config file should contain
          | Key     | Value |
          | enabled | 0     |
          | stream  |       |
        And the command exit code is 1
        And the command stderr should match exactly
           """
           Error: No stream specified for 'ModuleB', please specify stream

           """

  Scenario: "dnf module profile" without any additional arguments should raise an error
       When I run "dnf module profile"
       Then the command exit code is 1
        And the command stderr should match exactly
           """
           Error: dnf module profile: too few arguments

           """

  Scenario: having default stream defined in a system profile "dnf module profile DisabledModule" should list all profiles in a default stream
      Given a file "/etc/dnf/modules.defaults.d/ModuleB.yaml" with
           """
           document: modulemd-defaults
           version: 1
           data:
             module: ModuleB
             stream: f26
             profiles:
               f26: [default]
           """
       When I successfully run "dnf module profile ModuleB"
       Then the command stdout should match line by line regexp
           """
           ?Last metadata expiration check

           Name +: ModuleB:f26:2
           default +: Test.*
           ? +: TestI.*
           """
