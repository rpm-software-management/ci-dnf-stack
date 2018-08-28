Feature: Profile named ‘default’ is used when there are no modulemd defaults

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-5.setup"
       When I enable repository "modularityConf"
        And I successfully run "dnf makecache"

  Scenario: Existing profile named ‘default’ is used when there are no modulemd defaults
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfPD1:salt"
       Then a module ModuleConfPD1 config file should contain
         | Key      | Value   |
         | state     | enabled |
         | stream   | salt    |
         | profiles | default |
        And rpmdb changes are
         | State     | Packages                 |
         | installed | TestConfA/1-1.modConfPD1 |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfPD1:salt"
        And I successfully run "dnf -y module disable ModuleConfPD1:salt"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1568165
  Scenario: Profile named ‘default’ is created when there are no modulemd defaults and it is not available
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfND1:salt"
       Then a module ModuleConfND1 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | salt    |
         | profiles | default |
        And rpmdb does not change
