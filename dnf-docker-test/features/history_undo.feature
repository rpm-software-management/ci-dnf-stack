Feature: history undo install and erase - test reason of undone packages

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
         | Package | Tag       | Value |
         | TestA   |           |       |
         | TestB   | Requires  | TestC |
         | TestC   |           |       |
      Given repository "update" with packages
         | Package | Tag       | Value |
         | TestD   | Requires  | TestE |
         | TestE   | Obsoletes | TestA |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf install -y TestA"
       Then rpmdb changes are
         | State        | Packages     |
         | installed    | TestA        |

  Scenario: Handle package install
       When I save rpmdb
        And I enable repository "update"
        And I successfully run "dnf install -y TestD"
       Then rpmdb changes are
         | State        | Packages     |
         | installed    | TestD, TestE |
         | removed      | TestA        |
       When I save rpmdb
        And I successfully run "dnf history undo last -y"
       Then rpmdb changes are
         | State        | Packages     |
         | removed      | TestD, TestE |
         | installed    | TestA        |

  Scenario: Handle package erase
      When I save rpmdb
       And I successfully run "dnf install -y TestB"
      Then rpmdb changes are
        | State        | Packages     |
        | installed    | TestB, TestC |
      When I save rpmdb
       And I successfully run "dnf remove -y TestB"
      Then rpmdb changes are
        | State        | Packages     |
        | removed      | TestB, TestC |
      When I save rpmdb
       And I successfully run "dnf history undo last -y"
      Then rpmdb changes are
        | State        | Packages     |
        | installed    | TestB, TestC |
      When I save rpmdb
       And I successfully run "dnf remove -y TestC"
      Then rpmdb changes are
        | State        | Packages     |
        | removed      | TestB, TestC |
