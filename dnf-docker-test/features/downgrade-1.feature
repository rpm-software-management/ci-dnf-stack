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

 When I "install" a package "TestD" with "dnf"
 Then package "TestD, TestE" should be "installed"
 When I execute "dnf" command "-y downgrade TestD" with "fail"
 Then package "TestD, TestE" should be "unupgraded"
 When I execute "dnf" command "-y downgrade --allowerasing TestD" with "success"
 Then package "TestD, TestE" should be "downgraded"

 When I "install" a package "TestN" with "dnf"
 Then package "TestN" should be "installed"
 When I execute "dnf" command "-y downgrade TestN" with "success"
 Then package "TestN-1.0.0-3" should be "downgraded"
