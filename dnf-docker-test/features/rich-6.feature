Feature: Richdeps/Behave test
 TestA `Requires: (TestB and ((TestC or TestE) if TestD))` and TestF `Conflicts: TestC`

Scenario:
  Given I use the repository "rich-3"
  When I "install" a package "TestD, TestF" with "rpm"
  Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestD, TestF  |
  When I "install" a package "TestA" with "dnf"
  Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestB, TestE  |
