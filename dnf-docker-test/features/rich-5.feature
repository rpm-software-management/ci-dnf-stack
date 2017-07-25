Feature: Richdeps/Behave test
 TestA `Requires: (TestB and ((TestC or TestE) if TestD))` and TestF `Conflicts: TestC`

Scenario: Install TestA that requires: '(TestB and ((TestC or TestE) if TestD))' and TestF 'Conflicts: TestC'
  Given _deprecated I use the repository "rich-3"
  When _deprecated I execute "dnf" command "-y install TestA" with "success"
  Then _deprecated transaction changes are as follows
   | State        | Packages                    |
   | installed    | TestA, TestB                |
   | absent       | TestC, TestD, TestE, TestF  |
