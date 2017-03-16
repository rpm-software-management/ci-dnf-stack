Feature: DNF/Behave test Repository packages reinstall

    @setup
    Scenario: Feature setup
        Given repository "test" with packages
           | Package | Tag      | Value |
           | TestA   | Requires | TestB |
           | TestB   | Requires | TestC |
           | TestC   |          |       |
         When I save rpmdb
          And I enable repository "test"
          And I successfully run "dnf install -y TestA"
         Then rpmdb changes are
           | State     | Packages            |
           | installed | TestA, TestB, TestC |

    Scenario: Reinstall packages from repository
         When I save rpmdb
          And I successfully run "dnf -y repository-packages test reinstall-old"
         Then rpmdb changes are
           | State       | Packages            |
           | reinstalled | TestA, TestB, TestC |

    Scenario: Reinstall packages from nonexistent repository - fail
         When I save rpmdb
         When I remove all repositories
          And I run "dnf -y repository-packages test reinstall-old"
         Then the command should fail
