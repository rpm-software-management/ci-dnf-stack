@xfail
Feature: DNF/Behave test (downgrade test)

Scenario: Downgrade TestA from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I execute "dnf" command "-y install TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
   | absent       | TestC         |
 When I execute "dnf" command "-y downgrade TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | downgraded   | TestA      |
   | present      | TestB      |
   | absent       | TestC      |

Scenario: Downgrade TestD from repository "upgrade_1" that require downgrade of dependency
 Given I use the repository "upgrade_1"
 When I execute "dnf" command "-y install TestD" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestD, TestE  |
 When I execute "dnf" command "-y downgrade TestD" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | downgraded   | TestD, TestE  |

Scenario: Downgrade TestN from repository "upgrade_1" only to previous version
 Given I use the repository "upgrade_1"
 When I execute "dnf" command "-y install TestN" with "success"
 Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestN      |
 When I execute "dnf" command "-y downgrade TestN" with "success"
 Then transaction changes are as follows
   | State        | Packages       |
   | downgraded   | TestN-1.0.0-3  |
