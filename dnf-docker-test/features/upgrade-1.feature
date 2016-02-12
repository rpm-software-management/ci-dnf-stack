Feature: DNF/Behave test (upgrade test - single packages)

Scenario: Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA, TestD, TestF" with "dnf"
 Then package "TestA, TestB, TestD, TestE, TestF, TestG, TestH" should be "installed"
 And package "TestC" should be "absent"

Scenario: Upgrade package TestA from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "upgrade" a package "TestA" with "dnf"
 Then package "TestA" should be "upgraded"
 And package "TestB" should be "unupgraded"

Scenario: Upgrade two packages from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "upgrade" a package "TestD, TestF" with "dnf"
 Then package "TestD, TestE, TestF, TestG" should be "upgraded"
 And package "TestH" should be "unupgraded"

 When I "install" a package "TestI, TestK" with "dnf"
 Then package "TestI, TestJ, TestK, TestM" should be "installed"

Scenario: Upgrade or downgrade to specific version with install command from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I execute "dnf" command "install -y TestN-1.0.0-3" with "success"
 Then package "TestN-1.0.0-3" should be "installed"
 When I execute "dnf" command "install -y TestN-1.0.0-4" with "success"
 Then package "TestN-1.0.0-4" should be "upgraded"
 When I execute "dnf" command "install -y TestN-1.0.0-2" with "success"
 Then package "TestN-1.0.0-2" should be "downgraded"
