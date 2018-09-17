Feature: DNF/Behave test test (Test if group preserve user installed dependent packages)

Scenario: Preserve user installed pkg TestO that requires TestC. TestC is part of group
  Given _deprecated I use the repository "test-1"
  When I save rpmdb
  And I successfully run "dnf group install Testgroup -y"
       Then rpmdb changes are
         | State      | Packages           |
         | installed  | TestA,TestB, TestC |
  When I save rpmdb
  And I successfully run "dnf install TestO -y"
       Then rpmdb changes are
         | State      | Packages           |
         | installed  | TestO              |
  # TestC should be protected because it is required by user installed pkg TestO
  # TestC reason should be changed from group to dep
  When I save rpmdb
  And I successfully run "dnf group remove Testgroup -y"
       Then rpmdb changes are
         | State      | Packages           |
         | removed    | TestA,TestB        |
  When I save rpmdb
  And I successfully run "dnf remove TestO -y"
       Then rpmdb changes are
         | State      | Packages           |
         | removed    | TestO,TestC        |
