Feature: Installing package from ursine repo

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityY"
        And I enable repository "ursineY"
        And I successfully run "dnf makecache"

  Scenario: I can install a package from ursine repo when the same pkg is available in non-enabled non-default module stream
       # bz1636390
       When I save rpmdb
        And I run "dnf install -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestY/2-1      |
       # cleanup
       When I save rpmdb
        And I run "dnf remove -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | removed   | TestY/2-1      |

  Scenario: I can't install a package from ursine repo when the same pkg is available in enabled non-default module stream
       When I save rpmdb
        And I successfully run "dnf clean all"
        And I run "dnf module enable -y ModuleY:f26"
        And I run "dnf install -y TestY"
       Then rpmdb changes are
       # the newest version from ursine repo is masked 
          | State     | Packages       |
          | installed | TestY/1-1.modY |
       # cleanup
       When I save rpmdb
        And I run "dnf remove -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | removed   | TestY/1-1.modY |

  Scenario: I can install a package from ursine repo when the same pkg is available in disabled non-default module stream
       When I save rpmdb
        And I run "dnf module disable -y ModuleY:f26"
        And I successfully run "dnf clean all"
        And I run "dnf install -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestY/2-1      |
       # cleanup
       When I save rpmdb
        And I run "dnf remove -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | removed   | TestY/2-1      |
