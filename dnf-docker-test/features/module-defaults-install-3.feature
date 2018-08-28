Feature: On-disk modulemd data are preferred over repodata in case of a conflict

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-5.setup"
        And a file "/etc/dnf/modules.defaults.d/ModuleConfPD2.yaml" with
          """
          ---
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleConfPD2
            stream: pepper
            profiles:
              salt: [bacon]
              pepper: [eggs]
          ...
          """
       When I enable repository "modularityConf"
        And I successfully run "dnf makecache"

  Scenario: Local system modulemd defaults override repo defaults
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfPD2"
       Then a module ModuleConfPD2 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | pepper  |
         | profiles | eggs    |
        And rpmdb changes are
         | State     | Packages                 |
         | installed | TestConfC/1-1.modConfPD2 |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfPD2:pepper"
        And I successfully run "dnf -y module disable ModuleConfPD2:pepper"

  Scenario: No local system modulemd defaults to override repo defaults
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfPD3"
       Then a module ModuleConfPD3 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | pepper  |
         | profiles | bacon   |
        And rpmdb changes are
         | State     | Packages                 |
         | installed | TestConfB/1-1.modConfPD3 |

