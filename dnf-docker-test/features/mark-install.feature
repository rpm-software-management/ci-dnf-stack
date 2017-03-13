Feature: Mark install

  @setup
  Scenario: Feature Setup
      Given repository "test" with packages
         | Package | Tag      | Value |
         | TestA   | Requires | TestB |
         | TestB   |          |       |
      When I save rpmdb
       And I enable repository "test"
       And I successfully run "dnf -y install TestA"
      Then rpmdb changes are
        | State     | Packages     |
        | installed | TestA, TestB |

  Scenario: Marking dependency as user-installed should not remove it automatically
       When I save rpmdb
        And I successfully run "dnf mark install TestB"
        And I successfully run "dnf -y remove TestA"
       Then rpmdb changes are
         | State   | Packages |
         | removed | TestA    |
       When I save rpmdb
        And I successfully run "dnf -y remove TestB"
       Then rpmdb changes are
         | State   | Packages |
         | removed | TestB    |

  Scenario: Mark on non-existent package
       When I run "dnf mark install I_doesnt_exist"
       Then the command should fail
