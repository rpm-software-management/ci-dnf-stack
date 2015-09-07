Feature: Richdeps/Behave test
 TestA `Requires: (TestB and ((TestC or TestE) if TestD))` and TestF `Conflicts: TestC`

Scenario: 
  Given I use the repository "test-3"
  When I "install" a package "TestD, TestF" with "rpm"
  Then package "TestD, TestF" should be "installed"
  When I "install" a package "TestA" with "dnf"
  Then package "TestA, TestB, TestE" should be "installed"
