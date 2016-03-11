Feature: DNF/Behave test (upgrade test - ALL)

Scenario: Preparation - Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA, TestD, TestF, TestK" with "dnf"
 Then transaction changes are as follows
   | State        | Packages                                                       |
   | installed    | TestA, TestB, TestD, TestE, TestF, TestG, TestH, TestK, TestM  |
   | absent       | TestC                                                          |


Scenario: Upgrade ALL using '*' from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I execute "dnf" command "upgrade -y '*'" with "success"
 Then transaction changes are as follows
   | State        | Packages                                                |
   | upgraded     | TestA, TestB, TestD, TestE, TestF, TestG, TestH, TestM  |
   | absent       | TestC                                                   |
   | present      | TestK                                                   |
