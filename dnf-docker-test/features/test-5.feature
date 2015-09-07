Feature: Richdeps/Behave test
 TestA `Requires: (TestB and ((TestC or TestE) if TestD))` and TestF `Conflicts: TestC`

Scenario: 
  Given I use the repository "test-3"
  When I "install" a package "TestA" with "dnf"
  Then package "TestB" should be "installed"
  And package "TestC, TestD, TestE, TestF" should be "absent"
