@noRHEL7
Feature: Richdeps/Behave test
  TestA requires (TestB or TestC), TestA recommends TestC
  Install TestB first with RPM, then install TestA
  with and observe if the Recommended TestC is also installed


Scenario: Install TestB first with RPM, then install TestA with DNF and observe if the Recommended TestC is also installed
  Given _deprecated I use the repository "rich-1"
  When _deprecated I execute "bash" command "rpm -Uvh  /repo/TestB*.rpm" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | installed    | TestB      |
  When _deprecated I execute "dnf" command "-y install TestA" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestC  |
