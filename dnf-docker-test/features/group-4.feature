Feature: DNF/Behave test test (Preserve userinstaled packages on group remove)

Scenario: User installed TestA should be not remove after group remove
  Given _deprecated I use the repository "test-1"
  When I save rpmdb
  And I successfully run "dnf install TestA -y"
       Then rpmdb changes are
         | State      | Packages           |
         | installed  | TestA, TestB       |
  When I save rpmdb
  And I successfully run "dnf group install Testgroup -y"
       Then rpmdb changes are
         | State      | Packages           |
         | installed  | TestC              |
  # TestA should be protected because it is user installed pkg and not group installed
  When I save rpmdb
  And I successfully run "dnf group remove Testgroup -y"
       Then rpmdb changes are
         | State      | Packages           |
         | removed    | TestC              |
