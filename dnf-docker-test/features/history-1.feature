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
        And history should contain "install -y TestA" with action "Install" and "2" packages

    Scenario: Undo last transaction
        When I save rpmdb
          And I successfully run "dnf history undo last -y"
        Then rpmdb changes are
          | State        | Packages      |
          | removed      | TestA, TestB  |
        And history should contain "history undo last -y" with action "Erase" and "2" packages

    Scenario: Undo last transaction 2
        When I save rpmdb
          And I successfully run "dnf history undo last -y"
        Then rpmdb changes are
          | State        | Packages      |
          | installed    | TestA, TestB  |
        And history should contain "history undo last -y" with action "Install" and "2" packages

    Scenario: Undo transaction last-2
        When I save rpmdb
          And I successfully run "dnf history undo last-2 -y"
        Then rpmdb changes are
          | State        | Packages      |
          | removed      | TestA, TestB  |
        And history should contain "history undo last-2 -y" with action "Erase" and "2" packages

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
        And history should contain "history redo last-1 -y" with action "Install" and "2" packages
        When I save rpmdb
          And I successfully run "dnf history redo last-1 -y"
        Then rpmdb changes are
          | State        | Packages      |
          | removed      | TestA, TestB  |
        And history should contain "history redo last-1 -y" with action "Erase" and "2" packages

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
        Then history should contain "update -y" with action "Update" and "4" package
