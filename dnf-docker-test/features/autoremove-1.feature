Feature: DNF/Behave test (autoremove test)

Scenario: Install packages from repository "test-1"
 Given I use the repository "test-1"
 When I "install" a package "TestF" with "dnf"
 Then transaction changes are as follows
   | State        | Packages             |
   | installed    | TestF, TestG, TestH  |

Scenario: Upgrade packages from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "upgrade" a package "TestF" with "dnf"
 Then transaction changes are as follows
   | State        | Packages      |
   | upgraded     | TestF, TestG  |
   | present      | TestH         |

Scenario: Autoremove packages from repository "upgrade_1"
 Given I use the repository "upgrade_1"
 When I "autoremove" a package "TestF" with "dnf"
 Then transaction changes are as follows
   | State        | Packages      |
   | present      | TestF, TestG  |
   | removed      | TestH         |
