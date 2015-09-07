Feature: Richdeps/Behave test
  TestA requires (TestB and (TestC if TestD))

Scenario: 
  Given I use the repository "test-2"
  When I "install" a package "TestD" with "rpm"
  Then package "TestD" should be "installed"
  When I "install" a package "TestA" with "dnf"
  Then package "TestB, TestC, TestD" should be "installed"
