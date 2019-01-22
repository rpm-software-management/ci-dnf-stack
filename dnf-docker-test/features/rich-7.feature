@noRHEL7
Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario: Install TestD with rpm and then TestA that requires: TestC if (TestB or TestD)
  Given _deprecated I use the repository "rich-4"
  When _deprecated I execute "bash" command "rpm -Uvh  /repo/TestD*.rpm" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | installed    | TestD      |
  When _deprecated I execute "dnf" command "-y install TestA" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | installed    | TestA, TestC  |
