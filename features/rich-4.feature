Feature: Richdeps/Behave test
  TestA requires (TestB and (TestC if TestD))

Scenario: 
  Given I use the repository "rich-2"
  When I "install" a package "TestD" with "rpm"
  Then package "TestD" should be "installed"
  When I "install" a package "TestA" with "dnf"
  Then package "TestA, TestB, TestC" should be "installed"
