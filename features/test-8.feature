Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario: 
  Given I use the repository "test-4"
  When I "install" a package "TestA, TestC, TestD" with "rpm"
  Then package "TestA, TestC, TestD" should be "installed"
  When I "remove" a package "TestA, TestC" with "rpm"
  Then package "TestA, TestC" should be "removed"
