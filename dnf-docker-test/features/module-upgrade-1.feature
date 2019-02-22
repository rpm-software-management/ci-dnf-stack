Feature: Module upgrade

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf module enable ModuleA:f26 -y"
        And I save rpmdb
        And I successfully run "dnf install TestA-0:1-1.modA.noarch -y"
       Then a module "ModuleA" config file should contain
         | Key      | Value |
         | state    | enabled |
         | stream   | f26   |
        And rpmdb changes are
         | State     | Packages       |
         | installed | TestA/1-1.modA |

  @bz1647429
  Scenario: Upgrade module packages even if no profile installed
       When I save rpmdb
        And I successfully run "dnf module update ModuleA -y"
       Then a module "ModuleA" config file should contain
         | Key      | Value |
         | state    | enabled |
         | stream   | f26   |
        And rpmdb changes are
         | State     | Packages       |
         | updated   | TestA/1-2.modA |
