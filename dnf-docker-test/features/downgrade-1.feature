Feature: DNF/Behave test (downgrade test)

Scenario: Downgrade TestA from repository "upgrade_1"
 Given _deprecated I use the repository "upgrade_1"
 When _deprecated I execute "dnf" command "-y install TestA" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
   | absent       | TestC         |
 When _deprecated I execute "dnf" command "-y downgrade TestA" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | downgraded   | TestA      |
   | present      | TestB      |
   | absent       | TestC      |

Scenario: Downgrade TestD from repository "upgrade_1" that require downgrade of dependency
 Given _deprecated I use the repository "upgrade_1"
 When _deprecated I execute "dnf" command "-y install TestD" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestD, TestE  |
 When _deprecated I execute "dnf" command "-y downgrade TestD" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | downgraded   | TestD, TestE  |

Scenario: Downgrade TestN from repository "upgrade_1" only to previous version
 Given _deprecated I use the repository "upgrade_1"
 When _deprecated I execute "dnf" command "-y install TestN" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | installed    | TestN      |
 When _deprecated I execute "dnf" command "-y downgrade TestN" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | downgraded   | TestN-1.0.0-3  |
