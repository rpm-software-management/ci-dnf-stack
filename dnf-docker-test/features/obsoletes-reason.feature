Feature: Reason of obsoleted package
  Replaced package by "Obsoletes" must not be marked for autoremoval.

  Expects following tests to work:

  * Obsoleting packages one-to-one
  * Autoremoval of unneeded packages

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
         | Package | Tag       | Value |
         | TestA   |           |       |
        And repository "updates" with packages
         | Package | Tag       | Value |
         | TestB   | Obsoletes | TestA |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestA    |

  Scenario: Obsolete "TestA" with "TestB" and autoremove
       When I save rpmdb
        And I enable repository "updates"
        And I successfully run "dnf -y update"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestB    |
         | removed   | TestA    |
       When I save rpmdb
        And I successfully run "dnf -y autoremove"
       Then rpmdb does not change
