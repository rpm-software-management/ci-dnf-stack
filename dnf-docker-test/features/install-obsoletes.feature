Feature: Installing obsoleted packages

  @setup
  Scenario: Feature Setup
      Given repository "available" with packages
         | Package | Tag       | Value |
         | TestA   |           |       |
         | TestB   | Obsoletes | TestA |

  Scenario: Install "TestA" should be propagated to installing "TestB"
       When I save rpmdb
        And I enable repository "available"
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestB    |
