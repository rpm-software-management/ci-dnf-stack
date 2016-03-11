Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario:
  Given I use the repository "rich-4"
  When I "install" a package "TestD" with "rpm"
  Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestD      |
  When I "install" a package "TestA" with "dnf"
  Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestC  |
