Feature: Richdeps/Behave test
upgrade test - single packages

Scenario: Install TestA from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestB" should be "installed"
 And package "TestC" should be "absent"
 When I "install" a package "TestD" with "dnf"
 Then package "TestD, TestE" should be "installed"
 When I "install" a package "TestF" with "dnf"
 Then package "TestF, TestG, TestH" should be "installed"

Scenario: Install TestA from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "upgrade" a package "TestA" with "dnf"
 Then package "TestA" should be "upgraded"
 And package "TestB" should be "unupgraded"
 When I "upgrade" a package "TestD, TestF" with "dnf"
 Then package "TestD, TestE, TestF, TestG" should be "upgraded"
 And package "TestH" should be "unupgraded"
 When I "install" a package "TestI" with "dnf"
 Then package "TestI, TestJ" should be "installed"