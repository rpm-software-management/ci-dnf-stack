Feature: DNF/Behave test reinstall command

    @setup
    Scenario: Feature Setup
        Given repository "test" with packages
           | Package      | Tag      | Value      |
           | TestA        | Requires | TestA-libs |
           | TestA-libs   |          |            |
         When I save rpmdb
          And I enable repository "test"
          And I successfully run "dnf install -y TestA"
         Then rpmdb changes are
           | State       | Packages          |
           | installed   | TestA, TestA-libs |

    Scenario: Reinstall package
         When I save rpmdb
          And I enable repository "test"
          And I successfully run "dnf reinstall -y TestA-libs"
         Then rpmdb changes are
           | State        | Packages   |
           | reinstalled  | TestA-libs |

    Scenario: Reinstall - pkg not available
         When I save rpmdb
          And I disable repository "test"
          And I run "dnf reinstall -y TestA-libs"
         Then the command should fail
