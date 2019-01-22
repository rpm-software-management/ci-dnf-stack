@noRHEL7
Feature: Richdeps/Behave test
  TestA requires (TestB and (TestC if TestD))

Scenario: Install TestD with rpm, then TestA that requires (TestB and (TestC if TestD))
  Given _deprecated I use the repository "rich-2"
  When _deprecated I execute "bash" command "rpm -Uvh /repo/TestD*.rpm" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | installed    | TestD      |
  When _deprecated I execute "dnf" command "-y install TestA" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages             |
   | installed    | TestA, TestB, TestC  |
