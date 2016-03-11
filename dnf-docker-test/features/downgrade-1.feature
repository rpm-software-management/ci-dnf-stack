Feature: DNF/Behave test (downgrade test)

Scenario: Downgrade TestA from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "install" a package "TestA" with "dnf"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
   | absent       | TestC         |
 When I "downgrade" a package "TestA" with "dnf"
 Then transaction changes are as follows
   | State        | Packages   |
   | downgraded   | TestA      |
   | present      | TestB      |
   | absent       | TestC      |

Scenario: Downgrade TestD from repository "upgrade_1" that require --allowerasing
 Given I use the repository "upgrade_1"
 When I "install" a package "TestD" with "dnf"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestD, TestE  |
 When I execute "dnf" command "-y downgrade TestD" with "fail"
 Then transaction changes are as follows
   | State        | Packages      |
   | present      | TestD, TestE  |
 When I execute "dnf" command "-y downgrade --allowerasing TestD" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | downgraded   | TestD, TestE  |

Scenario: Downgrade TestN from repository "upgrade_1" only to previous version
 Given I use the repository "upgrade_1"
 When I "install" a package "TestN" with "dnf"
 Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestN      |
 When I execute "dnf" command "-y downgrade TestN" with "success"
 Then transaction changes are as follows
   | State        | Packages       |
   | downgraded   | TestN-1.0.0-3  |
