@noRHEL7
Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario: Rpm install-remove test with TestA that requires: TestC if (TestB or TestD)
  Given _deprecated I use the repository "rich-4"
  When _deprecated I execute "bash" command "rpm -Uvh /repo/TestA*.rpm /repo/TestC*.rpm /repo/TestD*.rpm" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestC, TestD  |
  When _deprecated I execute "bash" command "rpm -e TestA TestC" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages      |
   | removed      | TestA, TestC  |
