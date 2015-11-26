Feature: DNF/Behave test (downgrade test)

Scenario: Install TestA from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestB" should be "installed"
 And package "TestC" should be "absent"
 When I "downgrade" a package "TestA" with "dnf"
 Then package "TestA" should be "downgraded"
 And package "TestB" should be "unupgraded"
 And package "TestC" should be "absent"
