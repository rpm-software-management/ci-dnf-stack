Feature: Updating module profiles

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
        And I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityABDE"
        And I enable repository "modularityY"
        And I successfully run "dnf makecache"

  Scenario: I can update a module profile to a newer version
      Given I successfully run "dnf module enable -y ModuleA:f26"
        And I successfully run "dnf module install -y ModuleA:f26:1/client"
       When I save rpmdb
        And I successfully run "dnf module update --assumeyes ModuleA"
	Then rpmdb changes are
          | State     | Packages       |
          | upgraded  | TestA/1-2.modA |
          | unchanged | TestB/1-1.modA |

  @xfail
  # Dnf does not remove any packages as of now
  Scenario: I can update a module profile with package changes
      Given I successfully run "dnf module enable -y ModuleB:f26"
        And I successfully run "dnf module install -y ModuleB:f26:1"
       When I save rpmdb
        And I successfully run "dnf module update --assumeyes ModuleB"
	Then rpmdb changes are
          | State     | Packages |
          | upgraded  | TestG/1-2.modB |
          | removed   | TestH/1-1.modB |
          | installed | TestI/1-1.modB |

  Scenario: I try to update a module when no update is available
      Given I successfully run "dnf module enable -y ModuleA:f26"
        And I successfully run "dnf module install -y ModuleA:f26:2/client"
       When I save rpmdb
        And I run "dnf module update --assumeyes ModuleA"
       Then the command stdout should match regexp "Nothing to do."
        And rpmdb does not change
