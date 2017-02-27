Feature: Test for dnf check --duplicates command

  Scenario: Install package in version 1
      Given repository "base" with packages
         | Package      | Tag       | Value        |
         | TestA        | Version   | 1            |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages       |
         | installed | TestA          |
       When I successfully run "dnf check"
       Then the command stdout should be empty
        And the command stderr should be empty

  Scenario: Install package in version 2 and check for duplicates
      Given repository "base2" with packages
         | Package      | Tag       | Value        |
         | TestA        | Version   | 2            |
       When I enable repository "base2"
        And I successfully run "rpm -i TestA*.rpm" in repository "base2"
       Then the command should pass
       When I run "dnf check"
       Then the command should fail
        And the command stdout should match regexp "TestA.* is a duplicate with TestA-2.*"
        And the command stderr should match exactly
            """
            Error: Check discovered 1 problem(s)

            """
       When I run "dnf check --duplicates"
       Then the command should fail
        And the command stdout should match regexp "TestA.* is a duplicate with TestA-2.*"
        And the command stderr should match exactly
            """
            Error: Check discovered 1 problem(s)

            """
       When I run "dnf check --dependencies"
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
