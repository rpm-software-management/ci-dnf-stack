Feature: Autoremoval of unneeded packages

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
         | Package | Tag      | Value |
         | TestA   | Requires | TestB |
         | TestB   |          |       |
        And repository "updates" with packages
         | Package | Tag      | Value |
         | TestA   | Release  | 2     |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |

  Scenario: Autoremoval of package which became non-required by others
       When I save rpmdb
        And I enable repository "updates"
        And I successfully run "dnf -y update"
       Then rpmdb changes are
         | State     | Packages     |
         | upgraded  | TestA        |
         | unchanged | TestB        |
       When I save rpmdb
        And I successfully run "dnf -y autoremove"
       Then rpmdb changes are
         | State     | Packages     |
         | unchanged | TestA        |
         | removed   | TestB        |
