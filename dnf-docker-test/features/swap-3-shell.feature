@xfail
Feature: Test for swap command with package groups (run in dnf shell)

  @setup
  Scenario: Preparing the test repository
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

  Scenario: Installing the first set of packages
      Given I have dnf shell session opened with parameters "-y"
       When I save rpmdb
        And I run dnf shell command "repo enable base"
        And I run dnf shell command "group install GroupC"
        And I run dnf shell command "run"
       Then rpmdb changes are
         | State     | Packages           |
         | installed | TestC,TestC-subpkg |

  Scenario: Switch groups by swap command
      Given I have dnf shell session opened with parameters "-y"
       When I save rpmdb
        And I run dnf shell command "repo enable base"
        And I run dnf shell command "swap @GroupC @GroupD"
        And I run dnf shell command "run"
       Then rpmdb changes are
         | State      | Packages           |
         | installed  | TestD,TestD-subpkg |
         | removed    | TestC,TestC-subpkg |
