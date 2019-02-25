Feature: Installing module profiles - error handling

Background:
  Given I use the repository "dnf-ci-fedora-modular"
    And I use the repository "dnf-ci-fedora"


Scenario: A proper error message is displayed when I try to install a non-existent module
   When I execute dnf with args "module install NonExistentModule"
   Then the exit code is 1
    And stderr contains lines 
    """
    Error: Problems in request:
    missing groups or modules: NonExistentModule
    """

Scenario: A proper error message is displayed when I try to install a non-existent module using group syntax
   When I execute dnf with args "install @NonExistentModule"
   Then the exit code is 1
    And stderr contains lines 
    """
    Warning: Module or Group 'NonExistentModule' does not exist.
    Error: Nothing to do.
    """


Scenario: I cannot install an RPM with same name as an RPM that belongs to enabled MODULE:STREAM
   When I execute dnf with args "module disable ninja"
   Then the exit code is 0
   When I execute dnf with args "install ninja-build-0:1.8.2-5.fc29.x86_64"
   Then the exit code is 0
   When I execute dnf with args "remove ninja-build"
   Then the exit code is 0
   When I execute dnf with args "module enable ninja:master"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package                                       |
        | module-stream-enable      | ninja:master                                  |
   When I execute dnf with args "install ninja-build-0:1.8.2-5.fc29.x86_64"
   Then the exit code is 1
    And stderr contains lines 
    """
    Error: Unable to find a match
    """
    And stdout contains lines
    """
    No match for argument: ninja-build-0:1.8.2-5.fc29.x86_64
    """


# package FileConflict-1.0-1.x86_64 has file conflicts with
# FileConflict-0:2.0.streamB-1.x86_64 from module test-module

@xfail @bz1656782
Scenario: Profile is not installed after its artifact failed to get installed
  Given I use the repository "dnf-ci-fileconflicts"
   When I execute dnf with args "install FileConflict-1.0-1.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action                    | Package                           |
        | install                   | FileConflict-0:1.0-1.x86_64  |
   When I execute dnf with args "module install test-module:B/default"
   Then the exit code is 1
    And stderr contains "Error: Transaction check error:"
    And stderr contains "file /usr/lib/FileConflict/a_dir from install of FileConflict-0:2.0.streamB-1.x86_64 conflicts with file from package FileConflict-0:1.0-1.x86_64"
    And modules state is following
        | Module        | State     | Stream    | Profiles  |
        | test-module   | enabled   | B         |           |

