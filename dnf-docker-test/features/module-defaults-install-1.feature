Feature: Installing modules without cli profile specification, using profile overrides from repo

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-5.setup"
       When I enable repository "modularityConf"
        And I successfully run "dnf makecache"

  Scenario: Install module, empty 'default' profile exists, no repo or system overrides, expecting 'default' profile selection
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfED1:salt"
       Then a module ModuleConfED1 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | salt    |
         | profiles | default |
        And rpmdb does not change

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfED1:salt"
        And I successfully run "dnf -y module disable ModuleConfED1:salt"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1568165
  Scenario: Install module, 'default' profile does not exist, no repo or system overrides, expecting 'default' profile selection
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfND1:salt"
       Then a module ModuleConfND1 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | salt    |
         | profiles | default |
        And rpmdb does not change

  Scenario: Install module, populated 'default' profile exists, no repo or system overrides, expecting 'default' profile selection
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfPD1:salt"
       Then a module ModuleConfPD1 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | salt    |
         | profiles | default |
        And rpmdb changes are
         | State     | Packages                 |
         | installed | TestConfA/1-1.modConfPD1 |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfPD1:salt"
        And I successfully run "dnf -y module disable ModuleConfPD1:salt"

  Scenario: Install module, empty 'default' profile exists, repo profile override is 'default', expecting 'default' profile selection
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfED2:salt"
       Then a module ModuleConfED2 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | salt    |
         | profiles | default |
        And rpmdb does not change

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfED2:salt"
        And I successfully run "dnf -y module disable ModuleConfED2:salt"

  @xfail
  # https://bugzilla.redhat.com/show_bug.cgi?id=1568165
  Scenario: Install module, 'default' profile does not exist, repo profile override is 'default', expecting 'default' profile selection
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfND2:salt"
       Then a module ModuleConfND2 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | salt    |
         | profiles | default |
        And rpmdb does not change

  @xfail
  # due to previous scenario failure
  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfND2:salt"
        And I successfully run "dnf -y module disable ModuleConfND2:salt"

  Scenario: Install module, populated 'default' profile exists, repo profile override is 'default', expecting 'default' profile selection
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfPD2:salt"
       Then a module ModuleConfPD2 config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | salt    |
         | profiles | default |
        And rpmdb changes are
         | State     | Packages                 |
         | installed | TestConfA/1-1.modConfPD2 |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfPD2:salt"
        And I successfully run "dnf -y module disable ModuleConfPD2:salt"

  Scenario: Install module, empty 'default' profile exists, repo profile override is 'bacon', expecting 'bacon' profile selection
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfED3:pepper"
       Then a module ModuleConfED3 config file should contain
         | Key      | Value  |
         | state    | enabled|
         | stream   | pepper |
         | profiles | bacon  |
        And rpmdb changes are
         | State     | Packages                 |
         | installed | TestConfB/1-1.modConfED3 |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfED3:pepper"
        And I successfully run "dnf -y module disable ModuleConfED3:pepper"
