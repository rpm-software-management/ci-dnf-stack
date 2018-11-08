Feature: Installing package from ursine repo

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-7.setup"
       When I enable repository "modularityY"
        And I enable repository "ursineY"
        And I successfully run "dnf makecache"

  @bz1636390
  Scenario: I can install a package from ursine repo when the same pkg is available in non-enabled non-default module stream
       When I save rpmdb
        And I run "dnf install -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestY/2-1      |

  Scenario: I can see installed non-modular content listed in dnf list installed
       When I successfully run "dnf list --installed Test\*"
       Then the command stdout should match regexp "TestY.*2-1"
       When I successfully run "dnf module enable -y ModuleY:f26"
        And I successfully run "dnf clean all"
        And I successfully run "dnf list --installed Test\*"
       Then the command stdout should match regexp "TestY.*2-1"

  Scenario: I can't reinstall installed non-modular content which is masked by active modular content
       When I save rpmdb
        And I run "dnf reinstall -y TestY"
       Then the command should fail
        And rpmdb does not change

  Scenario: I can remove installed non-modular content
       When I save rpmdb
        And I run "dnf remove -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | removed   | TestY/2-1      |

  Scenario: I can't install a package from ursine repo when the same pkg is available in enabled non-default module stream
       When I save rpmdb
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

  Scenario: I can upgrade installed non-modular pkg by active modular content
       When I save rpmdb
        And I run "dnf module enable -y ModuleY:f27"
        And I successfully run "dnf clean all"
        And I run "dnf upgrade -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | upgraded  | TestY/3-1.modY |
