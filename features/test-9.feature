Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario: 
  Given I use the repository "test-4"
  When I "install" a package "TestA, TestC, TestD" with "rpm"
   Then package "TestA, TestC, TestD" should be "installed"
  When I "remove" a package "TestD" with "dnf"
   Then package "TestD" should be "removed"
  When I "remove" a package "TestC" with "dnf"
   Then package "TestC" should be "removed"
