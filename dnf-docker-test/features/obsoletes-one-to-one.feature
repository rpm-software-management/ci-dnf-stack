Feature: Obsoleting packages one-to-one

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
         | Package | Tag       | Value       |
         | TestA   |           |             |
        And repository "updates" with packages
         | Package | Tag       | Value       |
         | TestB   | Obsoletes | TestA < 1-2 |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestA    |

  Scenario: Update should replace one package with another
       When I save rpmdb
        And I enable repository "updates"
        And I successfully run "dnf -y update"
       Then rpmdb changes are
         | State     | Packages |
         | removed   | TestA    |
         | installed | TestB    |
