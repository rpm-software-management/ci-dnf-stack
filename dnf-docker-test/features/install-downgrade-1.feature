Feature: Installing package with lover version

  @setup
  Scenario: Feature Setup
      Given repository "available" with packages
         | Package   | Tag       | Value       |
         | TestA     | Version   | 1           |
         |           | Requires  | TestB = 1-1 |
         | TestA v2  | Version   | 2           |
         |           | Requires  | TestB = 2-1 |
         | TestB     | Version   | 1           |
         | TestB v2  | Version   | 2           |

  Scenario: Install "TestA" should be propagated to installing "TestB"
       When I save rpmdb
        And I enable repository "available"
        And I successfully run "dnf -y install TestA-2-1"
       Then rpmdb changes are
         | State     | Packages           |
         | installed | TestA/2, TestB/2   |

  Scenario: Install "TestA-1-1" should be propagated to installing "TestB-1-1"
       When I save rpmdb
        And I successfully run "dnf -y install TestA-1-1"
       Then rpmdb changes are
         | State      | Packages         |
         | downgraded | TestA/1, TestB/1 |
