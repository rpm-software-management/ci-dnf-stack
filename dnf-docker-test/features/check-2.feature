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
       When I run "dnf check --dependencies"
       Then the command should fail
       When I run "dnf check --duplicates"
       Then the command should pass
       When I run "dnf check --obsoleted"
       Then the command should pass
       When I run "dnf check --provides"
       Then the command should pass

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
       When I run "dnf check --dependencies"
       Then the command should fail
       When I run "dnf check --duplicates"
       Then the command should pass
       When I run "dnf check --obsoleted"
       Then the command should pass
       When I run "dnf check --provides"
       Then the command should pass
