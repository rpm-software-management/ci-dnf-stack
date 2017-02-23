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

    Scenario: List userinstalled
        When I save rpmdb
          And I successfully run "dnf install -y TestA TestE"
        Then history userinstalled should
          | Action    | Packages     |
          | Match     | TestA, TestE |
          | Not match | TestB, TestC |

    Scenario: History info


    Scenario: History info in range


    Scenario: History info package


    Scenario: History list ranges


    Scenario: History list single


    Scenario: History list package

    Scenario: List reponame
