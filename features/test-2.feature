Feature: Richdeps/Behave test
 TestA requires (TestB OR TestC), TestA recommends TestC

Scenario: Install TestA from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestB" with "rpm"
 Then package "TestB" should be "installed"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestC" should be "installed"
