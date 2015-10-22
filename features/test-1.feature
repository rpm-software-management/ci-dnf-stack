Feature: Richdeps/Behave test
 TestA requires TestB,

Scenario: Install TestA from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestB" should be "installed"
 And package "TestC" should be "absent"
 When I "remove" a package "TestA" with "dnf"
 Then package "TestA, TestB" should be "removed"
 And package "TestC" should be "absent"

