Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario:
  Given I use the repository "rich-4"
  When I "install" a package "TestA, TestC, TestD" with "rpm"
   Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestC, TestD  |
  When I "remove" a package "TestD" with "dnf"
   Then transaction changes are as follows
   | State        | Packages   |
   | removed      | TestD      |
  When I "remove" a package "TestC" with "dnf"
   Then transaction changes are as follows
   | State        | Packages   |
   | removed      | TestC      |
