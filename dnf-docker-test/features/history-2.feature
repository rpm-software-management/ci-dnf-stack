Feature: DNF/Behave test Transaction history [info, list, userinstalled]

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

    Scenario: List userinstalled packages
         When I save rpmdb
          And I successfully run "dnf install -y TestA TestE"
         Then history userinstalled should
           | Action    | Packages     |
           | Match     | TestA, TestE |
           | Not match | TestB, TestC |

    Scenario: History list last and range
         When I save rpmdb
          And I successfully run "dnf install -y TestD"
          And I successfully run "dnf remove -y TestE"
         Then history "last-1..last" should match "install -y TestD" with "Install" and "1" package
          And history "list last-1..last" should match "remove -y TestE" with "Erase" and "3" packages
          And history "last" should match "remove -y TestE" with "Erase" and "3" packages

    Scenario: History list package
         When I save rpmdb
          And I successfully run "dnf install -y TestC"
         Then history "TestC" should match "install -y TestC" with "Install" and "1" package
          And history "list TestC" should match "remove -y TestE" with "Erase" and "3" packages

    Scenario: History info
         When I save rpmdb
         Then history info should match
           | Key          | Value            |
           | Command Line | install -y TestC |
           | Return-Code  | Success          |
           | Install      | TestC            |
         When I successfully run "dnf remove -y TestA"
         Then history info should match
           | Key          | Value            |
           | Command Line | remove -y TestA  |
           | Return-Code  | Success          |
           | Erase        | TestA, TestB     |

    Scenario: History info in range
         When I save rpmdb
          And I successfully run "dnf install -y TestA"
         Then history info should match
           | Key          | Value            |
           | Command Line | install -y TestA |
           | Return-Code  | Success          |
           | Install      | TestA, TestB     |
         When I save rpmdb
          And I enable repository "updates"
          And I successfully run "dnf update -y"
         Then history info should match
           | Key          | Value            |
           | Command Line | update -y        |
           | Return-Code  | Success          |
           | Upgrade      | TestA, TestB     |
           | Upgraded     | TestA, TestB     |
          And history info "last-2..last" should match
           | Key          | Value            |
           | Return-Code  | Success          |
           | Upgrade      | TestA, TestB     |
           | Upgraded     | TestA, TestB     |
           | Install      | TestA, TestB     |
           | Erase        | TestA, TestB     |
          And history info "TestA" should match
           | Key          | Value                      |
           | Return-Code  | Success                    |
           | Upgrade      | TestA, TestB               |
           | Upgraded     | TestA, TestB               |
           | Install      | TestA, TestB, TestC, TestE |
           | Erase        | TestA, TestB               |
