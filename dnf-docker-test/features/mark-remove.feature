Feature: Mark remove

  @setup
  Scenario: Feature Setup
      Given repository "available" with packages
         | Package | Tag      | Value |
         | TestA   | Requires | TestC |
         | TestB   | Requires | TestC |
         | TestC   |          |       |
       When I save rpmdb
        And I enable repository "available"
        And I successfully run "dnf -y install TestA TestB"
       Then rpmdb changes are
         | State     | Packages            |
         | installed | TestA, TestB, TestC |

  Scenario: Marking toplevel package as for removal should not remove dependencies
       When I save rpmdb
        And I successfully run "dnf mark remove TestA"
        And I successfully run "dnf -y autoremove"
       Then rpmdb changes are
         | State        | Packages |
         | removed      | TestA    |

       When I save rpmdb
        And I successfully run "dnf mark remove TestB"
        And I successfully run "dnf -y autoremove"
       Then rpmdb changes are
         | State        | Packages     |
         | removed      | TestB, TestC |
