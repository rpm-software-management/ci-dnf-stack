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
            Error: No stream specified for 'ModuleA', please specify stream

            """

  Scenario: Enabling a module stream by refering the wrong version should fail
       When I run "dnf module enable ModuleA:f26:99 -y"
       Then the command exit code is 1
        And the command stderr should match exactly
            """
            Error: No such module: ModuleA:f26:99

            """

  Scenario: Enabling a non-existent module stream should fail
       When I run "dnf module enable ModuleA:f00 --assumeyes"
       Then the command exit code is 1
        And the command stderr should match exactly
            """
            Error: No such module: ModuleA:f00

            """

  Scenario: Enabling a non-existent module:stream should fail
       When I run "dnf module enable NoSuchModule:f00 --assumeyes"
       Then the command exit code is 1
        And the command stderr should match exactly
            """
            Error: No such module: NoSuchModule:f00

            """
