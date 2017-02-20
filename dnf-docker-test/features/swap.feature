@xfail
Feature: Test for swap command

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
         | Package | Tag       | Value  |
         | TestA   | Requires  | TestB  |
         | TestC   | Provides  | TestB  |
         |         | Conflicts | TestD  |
         | TestD   | Provides  | TestB  |
         |         | Conflicts | TestC  |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestC"
       Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestC |

  Scenario: Switch packages by swap command
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y swap TestC TestD"
       Then rpmdb changes are
         | State      | Packages     |
         | installed  | TestD        |
         | removed    | TestC        |
