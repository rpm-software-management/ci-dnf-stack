Feature: DNF/Behave test (autoremove test)

Scenario: Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestF" with "dnf"
 Then package "TestF, TestG, TestH" should be "installed"

Scenario: Upgrade packages from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "upgrade" a package "TestF" with "dnf"
 Then package "TestF, TestG" should be "upgraded"
 And package "TestH" should be "unupgraded"

Scenario: Autoremove packages from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "autoremove" a package "TestF" with "dnf"
 Then package "TestF, TestG" should be "present"
 And package "TestH" should be "removed"
