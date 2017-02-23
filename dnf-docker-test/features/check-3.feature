Feature: Test for dnf check --obsoleted command

  Scenario: Force install package that obsoletes already installed package
      Given repository "base" with packages
         | Package      | Tag       | Value        |
         | TestA        |           |              |
         | TestB        | Obsoletes | TestA        |
       When I enable repository "base"
        And I successfully run "rpm -i --nodeps TestA*.rpm" in repository "base"
       Then the command should pass
       When I run "dnf check"
       Then the command should pass
       When I successfully run "rpm -i --nodeps TestB*.rpm" in repository "base"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
       When I run "dnf check"
       Then the command should fail
        And the command stdout should match regexp "TestA-1.* is obsoleted by TestB-1.*"
        And the command stderr should match exactly
            """
            Error: Check discovered 1 problem(s)

            """
       When I run "dnf check --obsoleted"
       Then the command should fail
        And the command stdout should match regexp "TestA-1.* is obsoleted by TestB-1.*"
        And the command stderr should match exactly
            """
            Error: Check discovered 1 problem(s)

            """
       When I run "dnf check --duplicates"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
       When I run "dnf check --dependencies"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
       When I run "dnf check --provides"
       Then the command should pass
        And the command stdout should be empty
        And the command stderr should be empty
