Feature: DNF/Behave test (upgrade test - single packages)

Scenario: Install packages from repository "test-1"
 Given _deprecated I use the repository "test-1"
 When _deprecated I execute "dnf" command "-y install TestA TestD TestF" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages                                         |
   | installed    | TestA, TestB, TestD, TestE, TestF, TestG, TestH  |
   | absent       | TestC                                            |

Scenario: Upgrade package TestA from repository "upgrade_1"
 Given _deprecated I use the repository "upgrade_1"
 When _deprecated I execute "dnf" command "-y upgrade TestA" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages   |
   | upgraded     | TestA      |
   | present      | TestB      |

@bz1670776 @bz1671683
Scenario: Upgrade two packages from repository "upgrade_1"
 Given _deprecated I use the repository "upgrade_1"
 When _deprecated I execute "dnf" command "-y upgrade TestD TestF" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages                    |
   | upgraded     | TestD, TestE, TestF, TestG  |
   | present      | TestH                       |

 When _deprecated I execute "dnf" command "-y install TestI TestK" with "fail"
 When _deprecated I execute "dnf" command "-y install TestI TestK --nobest" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages                    |
   | installed    | TestI, TestJ, TestK, TestM  |

Scenario: Upgrade or downgrade to specific version with install command from repository "upgrade_1"
 Given _deprecated I use the repository "upgrade_1"
 When _deprecated I execute "dnf" command "install -y TestN-1.0.0-3" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | installed    | TestN-1.0.0-3  |
 When _deprecated I execute "dnf" command "install -y TestN-1.0.0-4" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | upgraded     | TestN-1.0.0-4  |
 When _deprecated I execute "dnf" command "install -y TestN-1.0.0-2" with "success"
 Then _deprecated transaction changes are as follows
   | State        | Packages       |
   | downgraded   | TestN-1.0.0-2  |
