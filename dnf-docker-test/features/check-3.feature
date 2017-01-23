Feature: Test for dnf check --obsoleted command

  Scenario: Force install package that obsoletes already installed package
      Given repository "base" with packages
         | Package      | Tag       | Value        |
         | TestA        |           |              |
         | TestB        | Obsoletes | TestA        |
       When I enable repository "base"
        And I execute rpm command "-i --nodeps TestA*.rpm" from repository "base"
       Then I execute "dnf" command "check --dependencies" with "success"
        And I execute "dnf" command "check --duplicates" with "success"
        And I execute "dnf" command "check --obsoleted" with "success"
        And I execute "dnf" command "check --provides" with "success"
        And I execute "dnf" command "check" with "success"
       When I execute rpm command "-i --nodeps TestB*.rpm" from repository "base"
       Then I execute "dnf" command "check --dependencies" with "success"
        And I execute "dnf" command "check --duplicates" with "success"
        And I execute "dnf" command "check --obsoleted" with "fail"
        And I execute "dnf" command "check --provides" with "success"
        And I execute "dnf" command "check" with "fail"
