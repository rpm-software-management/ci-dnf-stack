@noRHEL7
Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario: Install TestA TestC TestD with rpm then remove TestD and then remove TestC (TestA requires: TestC if (TestB or TestD))
  Given _deprecated I use the repository "rich-4"
  When _deprecated I execute "bash" command "rpm -Uvh /repo/TestA*.rpm /repo/TestC*.rpm /repo/TestD*.rpm" with "success"
   Then _deprecated transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestC, TestD  |
  When _deprecated I execute "dnf" command "-y remove TestD" with "success"
   Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | removed      | TestD      |
  When _deprecated I execute "dnf" command "-y remove TestC" with "success"
   Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | removed      | TestC      |
