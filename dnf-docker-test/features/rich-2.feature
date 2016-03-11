Feature: Richdeps/Behave test
  TestA requires (TestB or TestC), TestA recommends TestC
  Install TestB first with RPM, then install TestA
  with and observe if the Recommended TestC is also installed


Scenario:
  Given I use the repository "rich-1"
  When I execute "bash" command "rpm -Uvh  /repo/TestB*.rpm" with "success"
  Then transaction changes are as follows
   | State        | Packages   |
   | installed    | TestB      |
  When I execute "dnf" command "-y install TestA" with "success"
  Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestC  |
