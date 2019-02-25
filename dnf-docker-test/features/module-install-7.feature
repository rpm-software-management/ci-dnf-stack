Feature: Profile installation errors

# package FileConflict-1.0-1.x86_64 has file conflicts with
# FileConflict-0:2.0.streamB-1.x86_64 from module test-module

@xfail @bz1680684
Scenario: Profile is not installed after its artifact failed to get installed
  Given _deprecated I use the repository "fileconflicts"
   When I save rpmdb
    And I successfully run "dnf -y install FileConflict-1.0-1.x86_64"
   Then the command should pass
    And rpmdb changes are
        | State        | Packages                               |
        | installed    | FileConflict                           |
   When I run "dnf -y module install TestModule:B/default"
   Then the command should fail
    And the command stderr should match regexp "Error: Transaction check error:"
    And the command stderr should match regexp "file /usr/lib/FileConflict/a_dir from install of FileConflict-0:2.0.streamB-1.x86_64 conflicts with file from package FileConflict-0:1.0-1.x86_64"
    And a module TestModule config file should contain
        | Key      | Value                 |
        | profiles | (set)                 |


   
