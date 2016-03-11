Feature: Richdeps/Behave test
 TestA `Requires: (TestB and ((TestC or TestE) if TestD))` and TestF `Conflicts: TestC`

Scenario:
  Given I use the repository "rich-3"
  When I execute "bash" command "rpm -Uvh /repo/TestD*.rpm /repo/TestF*.rpm" with "success"
  Then transaction changes are as follows
   | State        | Packages      |
   | installed    | TestD, TestF  |
  When I execute "dnf" command "-y install TestA" with "success"
  Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestB, TestE  |
