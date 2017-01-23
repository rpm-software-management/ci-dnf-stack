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
       When I execute "dnf" command "check" with "success"

  Scenario: Install package in version 2 and check for duplicates
      Given repository "base2" with packages
         | Package      | Tag       | Value        |
         | TestA        | Version   | 2            |
       When I enable repository "base2"
        And I execute rpm command "-i TestA*.rpm" from repository "base2"
       Then I execute "dnf" command "check --duplicates" with "fail"
        And I execute "dnf" command "check --dependencies" with "success"
        And I execute "dnf" command "check --obsoleted" with "success"
        And I execute "dnf" command "check --provides" with "success"
        And I execute "dnf" command "check" with "fail"
