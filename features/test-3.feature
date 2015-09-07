Feature: Richdeps/Behave test
  TestA requires (TestB and (TestC if TestD))

Scenario: 
  Given I use the repository "test-2"
  When I "install" a package "TestA" with "dnf"
  Then package "TestA, TestB" should be "installed"
  And package "TestC, TestD" should be "absent"
