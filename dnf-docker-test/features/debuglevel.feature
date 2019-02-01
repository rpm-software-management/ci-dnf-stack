Feature: Tests for --debuglevel / -d cmdline option 

  @setup
  Scenario: Feature Setup
      Given local repository "base" with packages
          | Package     | Tag       | Value             |
          | TestA       | Version   | 1                 |
          |             | Release   | 1                 |
      When I enable repository "base"

  Scenario: Test for debuglevel 0
       When I run "dnf --assumeno -d0 install TestA"
       Then the command stderr should match regexp "Operation aborted"
        And the command stdout should be empty

  Scenario: Test for debuglevel 1
       When I run "dnf --assumeno --debuglevel=1 install TestA"
       Then the command stdout should match regexp "Installing:"
        And the command stdout should not match regexp "cachedir:"
        And the command stdout should not match regexp "Base command:"
        And the command stdout should not match regexp "timer: depsolve:"

  Scenario: Test for debuglevel 5
       When I run "dnf --assumeno -d=5 install TestA"
       Then the command stdout should match regexp "Installing:"
        And the command stdout should match regexp "cachedir:"
        And the command stdout should not match regexp "Base command:"
        And the command stdout should not match regexp "timer: depsolve:"

  Scenario: Test for debuglevel 10
       When I run "dnf --assumeno --debuglevel 10 install TestA"
       Then the command stdout should match regexp "Installing:"
        And the command stdout should match regexp "cachedir:"
        And the command stdout should match regexp "Base command:"
        And the command stdout should match regexp "timer: depsolve:"

  Scenario: Test for debuglevel greater than allowed value
       When I run "dnf --assumeno -d 100 install TestA"
       Then the command stderr should match regexp "Config error:.*should be less than allowed value"
        And the command stdout should be empty
