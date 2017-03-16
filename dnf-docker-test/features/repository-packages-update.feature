Feature: DNF/Behave test Repository packages update

    @setup
    Scenario: Feature setup
        Given repository "test" with packages
           | Package | Tag      | Value |
           | TestA   | Requires | TestB |
           | TestB   | Requires | TestC |
           | TestC   |          |       |
        Given repository "test2" with packages
           | Package | Tag      | Value |
           | TestA   | Version  | 2.0   |
           | TestB   | Version  | 2.0   |
        Given repository "test3" with packages
           | Package | Tag      | Value |
           | TestC   | Version  | 2.0   |
         When I save rpmdb
          And I enable repository "test"
          And I successfully run "dnf install -y TestA"
          And I enable repository "test3"
         Then rpmdb changes are
           | State     | Packages            |
           | installed | TestA, TestB, TestC |

    Scenario: Check for updates - no available
         When I run "dnf -q repository-packages test check-update"
         Then the command stdout should be empty

    Scenario: Check for updates - available
         When I run "dnf -q repository-packages test2 check-update"
         Then the command stdout should match
              """
              TestA.noarch                             2.0-1                             test2
              TestB.noarch                             2.0-1                             test2
              """
         When I run "dnf -q repository-packages test3 check-update"
         Then the command stdout should match
              """
              TestC.noarch                             2.0-1                             test3
              """

    Scenario: Update packages
         When I save rpmdb
          And I run "dnf -y repository-packages test2 upgrade"
         Then rpmdb changes are
           | State    | Packages     |
           | upgraded | TestA, TestB |
         When I save rpmdb
          And I run "dnf -y repository-packages test3 upgrade"
         Then rpmdb changes are
           | State    | Packages |
           | upgraded | TestC    |
