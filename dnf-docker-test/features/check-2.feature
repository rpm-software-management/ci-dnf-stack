Feature: Test for check --dependencies command

  @setup
  Scenario: Prepare "base" repository with test packages
      Given repository "base" with packages
         | Package      | Tag       | Value        |
         | TestA        | Requires  | TestB        |
         |              | Conflicts | TestC        |
         | TestB        |           |              |
         | TestC        |           |              |

  Scenario: Force installation of package with broken dependencies
       When I enable repository "base"
        And I successfully run "rpm -i --nodeps TestA*.rpm" in repository "base"
       Then the command should pass
       When I run "dnf check"
       Then the command should fail
        And the command stdout should match regexp "TestA-1.* has missing requires of TestB"
        And the command stderr should match exactly
            """
            Error: Check discovered 1 problem(s)

            """
       When I run "dnf check --dependencies"
       Then the command should fail
        And the command stdout should match regexp "TestA-1.* has missing requires of TestB"
        And the command stderr should match exactly
            """
            Error: Check discovered 1 problem(s)

            """
       When I run "dnf check --duplicates"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
       When I run "dnf check --obsoleted"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
       When I run "dnf check --provides"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty

  Scenario: Fulfill the missing dependencies
       When I enable repository "base"
        And I successfully run "dnf -y install TestB"
       When I run "dnf check"
       Then the command should pass

  Scenario: Force installation of conflicting package
       When I enable repository "base"
        And I successfully run "rpm -i --nodeps TestC*.rpm" in repository "base"
       Then the command should pass
       When I run "dnf check"
       Then the command should fail
        And the command stdout should match regexp "TestA-1.* has installed conflict "TestC": TestC-1.*"
        And the command stderr should match exactly
            """
            Error: Check discovered 1 problem(s)

            """
       When I run "dnf check --dependencies"
       Then the command should fail
        And the command stdout should match regexp "TestA-1.* has installed conflict "TestC": TestC-1.*"
        And the command stderr should match exactly
            """
            Error: Check discovered 1 problem(s)

            """
       When I run "dnf check --duplicates"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
       When I run "dnf check --obsoleted"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
       When I run "dnf check --provides"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
