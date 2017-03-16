Feature: DNF/Behave test Repository packages remove

    @setup
    Scenario: Feature setup
        Given repository "test" with packages
           | Package | Tag      | Value |
           | TestA   | Requires | TestB |
           | TestD   |          |       |
        Given repository "test2" with packages
           | Package | Tag      | Value |
           | TestB   |          |       |
           | TestC   | Requires | TestD |
        Given repository "test3" with packages
           | Package | Tag      | Value  |
           | TestD   |          |        |
        Given repository "test4" with packages
           | Package | Tag      | Value  |
           | TestC   |          |        |
         When I save rpmdb
          And I enable repository "test"
          And I enable repository "test2"
          And I successfully run "dnf install -y TestA TestC"
         Then rpmdb changes are
           | State     | Packages                   |
           | installed | TestA, TestB, TestC, TestD |

    Scenario: Remove packages from repository
         When I save rpmdb
          And I successfully run "dnf -y repository-packages test remove"
         Then rpmdb changes are
           | State   | Packages                   |
           | removed | TestA, TestB, TestC, TestD |

    Scenario: Remove or reinstall all packages from repository
         When I save rpmdb
          And I successfully run "dnf install -y TestA TestC"
         Then rpmdb changes are
           | State     | Packages                   |
           | installed | TestA, TestB, TestC, TestD |
         When I save rpmdb
          And I enable repository "test3"
          And I successfully run "dnf -y repository-packages test remove-or-reinstall"
         Then rpmdb changes are
           | State       | Packages     |
           | removed     | TestA, TestB |
           | reinstalled | TestD        |

    Scenario: Remove or reinstall single package from repository
         When I save rpmdb
          And I successfully run "dnf install -y TestB"
         Then rpmdb changes are
           | State     | Packages |
           | installed | TestB    |
         When I save rpmdb
          And I enable repository "test4"
          And I successfully run "dnf -y repository-packages test2 remove-or-reinstall TestC"
# FIXME - rpmdb changes doesn't work properly with reinstall
#         Then rpmdb changes are
#           | State       | Packages |
#           | reinstalled | TestC    |
         When I save rpmdb
          And I successfully run "dnf -y repository-packages test2 remove-or-reinstall TestB"
         Then rpmdb changes are
           | State   | Packages |
           | removed | TestB    |
