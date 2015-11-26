Feature: Richdeps/Behave test
 TestA `Requires: TestC if (TestB or TestD)`

Scenario: 
  Given I use the repository "rich-4"
  When I "install" a package "TestD" with "rpm"
  Then package "TestD" should be "installed"
  When I "install" a package "TestA" with "dnf"
  Then package "TestA, TestC" should be "installed"
