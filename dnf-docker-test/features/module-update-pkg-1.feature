Feature: Modular content is preferred over ursine content regardless on NVRs

  @setup
  Scenario: test setup
      Given I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityY"
        And I enable repository "ursineY"
        And I successfully run "dnf makecache"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1582436
  @xfail
  Scenario: updates from enabled stream overrides installed ursine rpm
      Given I successfully run "dnf install -y TestY-2-1"
       When I save rpmdb
        And I successfully run "dnf module enable ModuleY:f26 -y"
        And I successfully run "dnf module update -y ModuleY"
       Then rpmdb changes are
          | State      | Packages       |
          | downgraded | TestY/1-1.modY |
