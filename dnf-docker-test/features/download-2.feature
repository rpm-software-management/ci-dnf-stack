Feature: Test for download when there are multiple packages of the same NEVRA

  @setup
  Scenario: Feature Setup
      Given http repository "base" with packages
         | Package  | Tag       | Value  |
         | TestA    |           |        |
         | TestB    |           |        |
         | TestC    |           |        |
         | TestD    |           |        |
        And http repository "ext" with packages
         | Package  | Tag       | Value  |
         | TestA    |           |        |
         | TestB    |           |        |
         | TestC    |           |        |
         | TestD    |           |        |

  # https://bugzilla.redhat.com/show_bug.cgi?id=1612874
  @bz1612874
  Scenario: dnf download when there are multiple packages of the same NEVRA
       When I enable repository "base"
        And I enable repository "ext"
       When I successfully run "dnf download --destdir /tmp/testrpms TestA TestB TestC"
       Then the command stdout should match regexp "TestA-1.*rpm"
        And the command stdout should match regexp "TestB-1.*rpm"
        And the command stdout should match regexp "TestC-1.*rpm"
        # check that each file was being downloaded only once
        And the command stdout should not match regexp "TestA.*TestA"
        And the command stdout should not match regexp "TestB.*TestB"
        And the command stdout should not match regexp "TestC.*TestC"
        # check that the files have been downloaded into working directory
        And I successfully run "stat /tmp/testrpms/TestA-1-1.noarch.rpm"
        And I successfully run "stat /tmp/testrpms/TestB-1-1.noarch.rpm"
        And I successfully run "stat /tmp/testrpms/TestC-1-1.noarch.rpm"
        And I successfully run "bash -c 'rm -rf /tmp/testrpms'"
