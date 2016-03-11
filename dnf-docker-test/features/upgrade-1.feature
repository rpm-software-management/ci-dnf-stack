Feature: DNF/Behave test (upgrade test - single packages)

Scenario: Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestA, TestD, TestF" with "dnf"
 Then transaction changes are as follows
   | State        | Packages                                         |
   | installed    | TestA, TestB, TestD, TestE, TestF, TestG, TestH  |
   | absent       | TestC                                            |

Scenario: Upgrade package TestA from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "upgrade" a package "TestA" with "dnf"
 Then transaction changes are as follows
   | State        | Packages   |
   | upgraded     | TestA      |
   | present      | TestB      |

Scenario: Upgrade two packages from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "upgrade" a package "TestD, TestF" with "dnf"
 Then transaction changes are as follows
   | State        | Packages                    |
   | upgraded     | TestD, TestE, TestF, TestG  |
   | present      | TestH                       |

 When I "install" a package "TestI, TestK" with "dnf"
 Then transaction changes are as follows
   | State        | Packages                    |
   | installed    | TestI, TestJ, TestK, TestM  |

Scenario: Upgrade or downgrade to specific version with install command from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I execute "dnf" command "install -y TestN-1.0.0-3" with "success"
 Then transaction changes are as follows
   | State        | Packages       |
   | installed    | TestN-1.0.0-3  |
 When I execute "dnf" command "install -y TestN-1.0.0-4" with "success"
 Then transaction changes are as follows
   | State        | Packages       |
   | upgraded     | TestN-1.0.0-4  |
 When I execute "dnf" command "install -y TestN-1.0.0-2" with "success"
 Then transaction changes are as follows
   | State        | Packages       |
   | downgraded   | TestN-1.0.0-2  |
