Feature: Richdeps/Behave test (downgrade test)

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
TestK	2	TestJ >= 1.0.0-3
TestM	2	
TestN	1	
TestN	2	
TestN	3	
TestN	4	
Scenario: Install TestA from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "install" a package "TestA" with "dnf"
 Then package "TestA, TestB" should be "installed"
 And package "TestC" should be "absent"
 When I "downgrade" a package "TestA" with "dnf"
 Then package "TestA" should be "downgraded"
 And package "TestB" should be "unupgraded"
 And package "TestC" should be "absent"
