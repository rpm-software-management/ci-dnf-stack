Feature: Richdeps/Behave test
 Version of packages: 1.0.0-1
 TestA	Requires	TestB
 TestD	Requires	TestE = 1.0.0-1
 TestF	Requires	TestG >= 1.0.0-1, TestH = 1.0.0-1
 TestI	Requires	TestJ >= 1.0.0-2 (cannot be installed)
 TestK	Requires	TestM
 TestL	Requires	TestM

Scenario: Install TestA from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestB" should be "installed"
 And package "TestC" should be "absent"
 When I "remove" a package "TestA" with "dnf"
 Then package "TestA, TestB" should be "removed"
 And package "TestC" should be "absent"
 When I "install" a package "TestD" with "dnf"
 Then package "TestD, TestE" should be "installed"
 When I "remove" a package "TestD" with "dnf"
 Then package "TestD, TestE" should be "removed"
 When I "install" a package "TestF" with "dnf"
 Then package "TestF, TestG, TestH" should be "installed"
 When I "remove" a package "TestF" with "dnf"
 Then package "TestF, TestG, TestH" should be "removed"
 When I "notinstall" a package "TestI" with "dnf"
 Then package "TestI, TestJ" should be "absent"
 When I "install" a package "TestK, TestL" with "dnf"
 Then package "TestK, TestL, TestM" should be "installed"
 When I "remove" a package "TestK" with "dnf"
 Then package "TestK" should be "removed"
 And package "TestL, TestM" should be "absent"
 And package "TestL, TestM" should be "unupgraded"
 When I "remove" a package "TestL" with "dnf"
 Then package "TestL, TestM" should be "removed"