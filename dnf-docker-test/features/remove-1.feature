Feature: Test for dnf remove with excluded dependent package
 repo base: TestA-1 TestB-1
 repo ext: XTest-2 TestA-2 TestB-2

  @setup
  Scenario: Setup (create test repos)
      Given repository "base" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 1         |
         |              | Requires | TestB     |
         | TestB        | Version  | 1         |

      When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA"
      Then rpmdb changes are
        | State     | Packages     |
        | installed | TestA, TestB |

  Scenario: dnf remove (when there are such pkgs)
       When I save rpmdb
        And I run "dnf -y remove TestB -x TestA"
       Then the command should fail
        And rpmdb does not change
