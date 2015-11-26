Feature: DNF/Behave test (upgrade test - ALL)

Scenario: Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA, TestD, TestF, TestK" with "dnf"
 Then package "TestA, TestB, TestD, TestE, TestF, TestG, TestH, TestK, TestM" should be "installed"
 And package "TestC" should be "absent"


Scenario: Upgrade ALL from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I execute dnf command "-y upgrade" with "success"
 Then package "TestA, TestB, TestD, TestE, TestF, TestG, TestH, TestM" should be "upgraded"
 And package "TestC" should be "absent"
 And package "TestK" should be "unupgraded"
