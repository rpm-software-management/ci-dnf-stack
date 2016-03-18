Feature: Richdeps/Behave test
 TestA requires (TestB or TestC), TestA recommends TestC

Scenario: Install TestA that requires (TestB or TestC), TestA recommends TestC
 Given I use the repository "rich-1"
 When I execute "dnf" command "-y install TestA" with "success"
 Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestC  |
   | absent       | TestB         |
