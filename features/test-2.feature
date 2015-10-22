Feature: Richdeps/Behave test
upgrade test

Scenario: Install TestA from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestB" should be "installed"
 And package "TestC" should be "absent"

Scenario: Install TestA from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "upgrade" a package "TestA" with "dnf"
 Then package "TestA" should be "upgraded"
 And package "TestB" should be "unupgraded"
