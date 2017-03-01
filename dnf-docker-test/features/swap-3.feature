Feature: Test for swap command with package groups

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
         | Package      | Tag       | Value        |
         | TestA        | Requires  | TestB        |
         | TestC        | Provides  | TestB        |
         |              | Conflicts | TestD        |
         | TestC-subpkg | Requires  | TestC        |
         |              | Conflicts | TestD-subpkg |
         | TestD        | Provides  | TestB        |
         |              | Conflicts | TestC        |
         | TestD-subpkg | Requires  | TestD        |
         |              | Conflicts | TestC-subpkg |
      And package groups defined in repository "base"
         | Group   | Tag       | Value         |
         | GroupC  | mandatory | TestC         |
         |         | default   | TestC-subpkg  |
         | GroupD  | mandatory | TestD         |
         |         | default   | TestD-subpkg  |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y groupinstall GroupC"
       Then rpmdb changes are
         | State     | Packages           |
         | installed | TestC,TestC-subpkg |

  Scenario: Switch groups by swap command
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y swap @GroupC @GroupD"
       Then rpmdb changes are
         | State      | Packages           |
         | installed  | TestD,TestD-subpkg |
         | removed    | TestC,TestC-subpkg |
