@xfail
Feature: Test for swap command with wildcards package specification

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
         | Package      | Tag       | Value         |
         | TestA        | Requires  | TestB         |
         | TestC        | Provides  | TestB         |
         |              | Conflicts | TestD         |
         | TestC-subpkg | Requires  | TestC         |
         |              | Conflicts | TestD-subpkg  |
         | TestD        | Provides  | TestB         |
         |              | Conflicts | TestC         |
         | TestD-subpkg | Requires  | TestD         |
         |              | Conflicts | TestC-subpkg  |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestB TestC-subpkg"
       Then rpmdb changes are
         | State     | Packages                   |
         | installed | TestA, TestC, TestC-subpkg |

  Scenario: Switch packages and their subpackages by swap command
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y swap TestC\* TestD\*"
       Then rpmdb changes are
         | State      | Packages           |
         | installed  | TestD,TestD-subpkg |
         | removed    | TestC,TestC-subpkg |
