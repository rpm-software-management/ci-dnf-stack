Feature: Installing and removing profiles and RPMs for a locked module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"
        And I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module install -y ModuleA:f26:1/minimal"
        And I successfully run "dnf module install -y ModuleA:f26:1/devel"
        And I successfully run "dnf module lock ModuleA"
        And I successfully run "dnf module enable ModuleD:f26"
        And I successfully run "dnf module install -y ModuleD:f26:1/default"
        And I successfully run "dnf module lock ModuleD"

  Scenario: Having a locked module:stream I can still install profiles for a locked profile version
       When I save rpmdb
       When I successfully run "dnf module install -y ModuleA/client"
#TODO verify that profile has been successfully installed
       Then rpmdb changes are
            | State     | Packages  |
            | installed | TestB-1-1 |

  Scenario: Having a locked module:stream I can still remove profiles for a locked profile version
       When I save rpmdb
       When I successfully run "dnf module remove -y ModuleD/default"
#TODO verify that profile has been successfully removed
       Then rpmdb changes are
            | State   | Packages |
            | removed | TestM    |

  Scenario: Having a locked module:stream I can still install and remove rpms for a locked profile version
       When I save rpmdb
        And I successfully run "dnf install -y TestC"
        And I successfully run "dnf remove --assumeyes TestD"
       Then rpmdb changes are
            | State     | Packages  |
            | installed | TestC-1-1 |
            | removed   | TestD     |

  Scenario: Having a locked module:stream, I won't be getting an updates for an installed profile
      Given I successfully run "dnf module install -y ModuleB:f26:1/default"
        And I successfully run "dnf module lock ModuleB"
       When I save rpmdb
        And I successfully run "dnf module update --assumeyes ModuleB"
       Then rpmdb does not change
        And the command stdout should match line by line regexp
            """
            ?Last metadata expiration check:
            Dependencies resolved\.
            Nothing to do\.
            Complete!
            """
