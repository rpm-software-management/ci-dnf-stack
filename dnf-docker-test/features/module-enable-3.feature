Feature: Enabling module stream - error handling

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  Scenario: Enabling a module stream by specifying only the module name should fail
       When I run "dnf module enable ModuleA -y"
       Then the command exit code is 1
        And the command stderr should match exactly
            """
            Cannot enable more streams from module 'ModuleA' at the same time
            Unable to resolve argument ModuleA
            Error: No match for one or more arguments

            """

  # https://bugzilla.redhat.com/show_bug.cgi?id=1629655
  @xfail @bz1629655
  Scenario: Enabling a module stream by refering the wrong version should fail
       When I run "dnf module enable ModuleA:f26:99 -y"
       Then the command exit code is 1
        And the command stderr should match exactly
            """
            Cannot find module profile ModuleA:f26:99
            Unable to resolve argument ModuleA:f26:99
            Error: No match for one or more arguments

            """

  # https://bugzilla.redhat.com/show_bug.cgi?id=1629655
  @xfail @bz1629655
  Scenario: Enabling a non-existent module stream should fail
       When I run "dnf module enable ModuleA:f00 --assumeyes"
       Then the command exit code is 1
        And the command stderr should match exactly
            """
            Cannot find module stream ModuleA:f00
            Unable to resolve argument ModuleA:f00
            Error: No match for one or more arguments

            """

  Scenario: module enable without specifying a name gives an error
        When I run "dnf module enable"
        Then the command exit code is 1
        And the command stderr should match regexp "Error: dnf module enable: too few arguments"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1581267
  @xfail @bz1581267
  Scenario: Enabling two streams for the same module gives an error
       When I run "dnf module enable ModuleA:f26 ModuleA:f27 --assumeyes"
       Then the command exit code is 1
       # TODO: check also stderr output
