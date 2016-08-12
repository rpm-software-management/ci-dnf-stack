Feature: "Reason" of reinstalled package
  Re-install must not change "reason" of package which has been installed
  as dependency.

  After reinstalling dependent package removal of main package should remove
  dependent package as well.

  @setup
  Scenario: Feature Setup
      Given repository "available" with packages
         | Package    | Tag      | Value      |
         | TestA      | Requires | TestA-libs |
         | TestA-libs |          |            |
       When I save rpmdb
        And I enable repository "available"
        And I successfully run "dnf -y install TestA"
       Then rpmdb changes are
         | State     | Packages          |
         | installed | TestA, TestA-libs |

  Scenario: Reinstall dependency, remove main package
       When I save rpmdb
        And I successfully run "dnf -y reinstall TestA-libs"
       Then rpmdb changes are
         | State       | Packages          |
         | reinstalled | TestA-libs        |
       When I save rpmdb
        And I successfully run "dnf -y remove TestA"
       Then rpmdb changes are
         | State       | Packages          |
         | removed     | TestA, TestA-libs |
