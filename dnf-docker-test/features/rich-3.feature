Feature: Richdeps/Behave test
  TestA requires (TestB and (TestC if TestD))

Scenario:
  Given I use the repository "rich-2"
  When I "install" a package "TestA" with "dnf"
  Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestB  |
   | absent       | TestC, TestD  |
