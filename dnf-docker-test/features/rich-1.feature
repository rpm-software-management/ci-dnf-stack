@noRHEL7
Feature: Richdeps/Behave test
 TestA requires (TestB or TestC), TestA recommends TestC

Scenario: Install TestA that requires (TestB or TestC), TestA recommends TestC
 Given _deprecated I use the repository "rich-1"
 When _deprecated I execute "dnf" command "-y install TestA" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestC  |
   | absent       | TestB         |
