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
        And I execute rpm command "-i --nodeps TestA*.rpm" from repository "base"
       Then I execute "dnf" command "check --dependencies" with "fail"
        And I execute "dnf" command "check --duplicates" with "success"
        And I execute "dnf" command "check --obsoleted" with "success"
        And I execute "dnf" command "check --provides" with "success"
        And I execute "dnf" command "check" with "fail"

  Scenario: Fulfill the missing dependencies
       When I enable repository "base"
        And I successfully run "dnf -y install TestB"
       Then I execute "dnf" command "check --dependencies" with "success"
        And I execute "dnf" command "check --duplicates" with "success"
        And I execute "dnf" command "check --obsoleted" with "success"
        And I execute "dnf" command "check --provides" with "success"
        And I execute "dnf" command "check" with "success"

  Scenario: Force installation of conflicting package
       When I enable repository "base"
        And I execute rpm command "-i --nodeps TestC*.rpm" from repository "base"
       Then I execute "dnf" command "check --dependencies" with "fail"
        And I execute "dnf" command "check --duplicates" with "success"
        And I execute "dnf" command "check --obsoleted" with "success"
        And I execute "dnf" command "check --provides" with "success"
        And I execute "dnf" command "check" with "fail"
