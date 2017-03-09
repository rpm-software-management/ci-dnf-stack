Feature: DNF/Behave test Transaction history - base

    @setup
    Scenario: Feature Setup
        Given repository "test" with packages
            | Package | Tag      | Value |
            | TestA   | Requires | TestB |
            | TestB   |          |       |
            | TestC   |          |       |
            | TestD   | Requires | TestE |
            | TestE   | Requires | TestC |
          And repository "updates" with packages
              | Package | Tag     | Value |
              | TestA   | Version | 2     |
              | TestB   | Version | 2     |
              | TestC   | Version | 2     |
              | TestD   | Version | 2     |
        When I save rpmdb
          And I enable repository "test"

    Scenario: Simple transaction
        When I save rpmdb
          And I successfully run "dnf install -y TestA"
        Then rpmdb changes are
          | State        | Packages      |
          | installed    | TestA, TestB  |
        And history should match "install -y TestA" with "Install" and "2" packages

    Scenario: Undo last transaction
        When I save rpmdb
          And I successfully run "dnf history undo last -y"
        Then rpmdb changes are
          | State        | Packages      |
          | removed      | TestA, TestB  |
        And history should match "history undo last -y" with "Erase" and "2" packages

    Scenario: Undo last transaction 2
        When I save rpmdb
          And I successfully run "dnf history undo last -y"
        Then rpmdb changes are
          | State        | Packages      |
          | installed    | TestA, TestB  |
        And history should match "history undo last -y" with "Install" and "2" packages

    Scenario: Undo transaction last-2
        When I save rpmdb
          And I successfully run "dnf history undo last-2 -y"
        Then rpmdb changes are
          | State        | Packages      |
          | removed      | TestA, TestB  |
        And history should match "history undo last-2 -y" with "Erase" and "2" packages

    Scenario: Redo last transaction
        When I save rpmdb
          And I successfully run "dnf install -y TestA"
        Then rpmdb changes are
          | State        | Packages      |
          | installed    | TestA, TestB  |
        When I save rpmdb
          And I successfully run "dnf remove -y TestA"
        Then rpmdb changes are
          | State        | Packages      |
          | removed      | TestA, TestB  |
        When I save rpmdb
          And I successfully run "dnf history redo last-1 -y"
        Then rpmdb changes are
          | State        | Packages      |
          | installed    | TestA, TestB  |
        And history should match "history redo last-1 -y" with "Install" and "2" packages
        When I save rpmdb
          And I successfully run "dnf history redo last-1 -y"
        Then rpmdb changes are
          | State        | Packages      |
          | removed      | TestA, TestB  |
        And history should match "history redo last-1 -y" with "Erase" and "2" packages

    Scenario: Update packages
        When I save rpmdb
          And I successfully run "dnf install -y TestA TestD"
        Then rpmdb changes are
          | State        | Packages                          |
          | installed    | TestA, TestB, TestC, TestD, TestE |
        When I save rpmdb
          And I enable repository "updates"
          And I successfully run "dnf update -y"
        Then rpmdb changes are
          | State        | Packages                    |
          | updated      | TestA, TestB, TestC, TestD  |
        When I successfully run "dnf history"
        Then history should match "update -y" with "Update" and "4" package

    Scenario: Rollback update
        When I save rpmdb
          And I successfully run "dnf history rollback last-1 -y"
        Then rpmdb changes are
          | State        | Packages                   |
          | downgraded   | TestA, TestB, TestC, TestD |
        When I save rpmdb
          And I successfully run "dnf history rollback last-3 -y"
        Then rpmdb changes are
          | State        | Packages                          |
          | removed      | TestA, TestB, TestC, TestD, TestE |
