Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario: Install TestA TestC TestD with rpm then remove TestD and then remove TestC (TestA requires: TestC if (TestB or TestD))
  Given I use the repository "rich-4"
  When I execute "bash" command "rpm -Uvh /repo/TestA*.rpm /repo/TestC*.rpm /repo/TestD*.rpm" with "success"
   Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestC, TestD  |
  When I execute "dnf" command "-y remove TestD" with "success"
   Then transaction changes are as follows
   | State        | Packages   |
   | removed      | TestD      |
  When I execute "dnf" command "-y remove TestC" with "success"
   Then transaction changes are as follows
   | State        | Packages   |
   | removed      | TestC      |
