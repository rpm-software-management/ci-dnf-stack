Feature: DNF/Behave test Repository packages remove-or-distro-sync

    @setup
    Scenario: Feature setup
        Given repository "distro1" with packages
           | Package | Tag     | Value |
           | TestA   |         |       |
           | TestB   |         |       |
           | TestC   |         |       |
           | TestD   |         |       |
        Given repository "distro2" with packages
           | Package | Tag     | Value |
           | TestA   | Version | 2.0   |
           | TestD   | Version | 2.0   |
         When I save rpmdb
          And I enable repository "distro1"
          And I successfully run "dnf install -y TestA TestB TestC TestD"
         Then rpmdb changes are
           | State     | Packages                   |
           | installed | TestA, TestB, TestC, TestD |

    Scenario: Sync package to latest version in available repositories
         When I save rpmdb
          And I enable repository "distro2"
          And I successfully run "dnf -y repository-packages distro1 remove-or-distro-sync TestA"
         Then rpmdb changes are
           | State    | Packages |
           | upgraded | TestA    |

    Scenario: Remove repository package
         When I save rpmdb
          And I enable repository "distro2"
          And I successfully run "dnf -y repository-packages distro1 remove-or-distro-sync TestB"
         Then rpmdb changes are
           | State    | Packages |
           | removed  | TestB    |

    Scenario: Remove or distrosync remaining packages from repository
         When I save rpmdb
          And I successfully run "dnf -y repository-packages distro1 remove-or-distro-sync"
         Then rpmdb changes are
           | State    | Packages |
           | removed  | TestC    |
           | upgraded | TestD    |

    Scenario: Distro-sync repo with no package installed
         When I run "dnf -y repository-packages distro1 remove-or-distro-sync"
         Then the command should fail

    Scenario: Distro-sync non-existent package
         When I run "dnf -y repository-packages distro1 remove-or-distro-sync I_doesnt_exist"
         Then the command should fail
