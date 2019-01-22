@noRHEL7
Feature: Richdeps/Behave test
 TestA `Requires: (TestB and ((TestC or TestE) if TestD))` and TestF `Conflicts: TestC`

Scenario: Install TestD and TestF with rpm and then TestA that requires: (TestB and ((TestC or TestE) if TestD))` and TestF `Conflicts: TestC`
  Given _deprecated I use the repository "rich-3"
  When _deprecated I execute "bash" command "rpm -Uvh /repo/TestD*.rpm /repo/TestF*.rpm" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestD, TestF  |
  When _deprecated I execute "dnf" command "-y install TestA" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestB, TestE  |
