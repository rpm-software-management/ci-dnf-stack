Feature: Richdeps/Behave test
 TestA requires (TestB or TestC), TestA recommends TestC

Scenario: Install TestA from repository "rich-1"
 Given I use the repository "rich-1"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestC" should be "installed"
 And package "TestB" should be "absent"
