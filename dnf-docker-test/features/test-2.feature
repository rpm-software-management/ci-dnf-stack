Feature: Richdeps/Behave test
upgrade test - single packages
Packages in upgrade_1 (name release requires)
TestA	1	TestB
TestB	1
TestC	1
TestD	1	TestE = 1.0.0-1
TestE	1
TestF	1	TestG >= 1.0.0-1, TestH = 1.0.0-1
TestG	1
TestH	1
TestI	1	TestJ >= 1.0.0-2
TestJ	1
TestK	1	TestM
TestL	1	TestM
TestM	1
TestA	2	TestB
TestB	2
TestC	2
TestD	2	TestE = 1.0.0-2
TestE	2
TestF	2	TestG >= 1.0.0-2
TestG	2
TestH	2
TestJ	2

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