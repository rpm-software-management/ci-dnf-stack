Feature: Tests for --errorlevel / -e cmdline option 

  @setup
  Scenario: Feature Setup
      Given local repository "base" with packages
          | Package     | Tag       | Value             |
          | TestA       | Version   | 1                 |
          |             | Release   | 1                 |
          |             | Requires  | TestB             |
       And local repository "ext" with packages
          | Package     | Tag       | Value             |
          | TestB       | Version   | 1                 |
          |             | Release   | 1                 |
          |             | Requires  | TestC             |
      When I enable repository "base"

  Scenario: Test for errorlevel 0
       When I run "dnf -y -e0 install TestA"
       Then the command should fail
        And the command stderr should be empty

  Scenario: Test for errorlevel 1
       When I run "dnf -y --errorlevel=1 install TestA"
       Then the command should fail
        And the command stderr should match regexp "Problem: conflicting requests"
        And the command stderr should match regexp "nothing provides TestB"

  Scenario: Test for errorlevel 5
       When I enable repository "ext"
        And I run "dnf -y -e=5 install TestA"
       Then the command should fail
        And the command stderr should match regexp "Problem:.*none of the providers can be installed"
        And the command stderr should match regexp "nothing provides TestC"

  Scenario: Test for errorlevel greater than allowed value
       When I run "dnf -y -e 33 install TestA"
       Then the command should fail
        And the command stderr should match regexp "Config error:.*should be less than allowed value"
