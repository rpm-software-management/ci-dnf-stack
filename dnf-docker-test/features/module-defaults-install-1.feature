Feature: Installing module profiles with and without defaults

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-5.setup"
       When I enable repository "modularityConf"
        And I successfully run "dnf makecache"

  Scenario: Installing a module stream with no system and no cli profile specification uses empty 'default' profile which exists
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfED1:s-default"
       Then a module ModuleConfED1 config file should contain
         | Key      | Value     |
         | enabled  | 1         |
         | stream   | s-default |
         | version  | 1         |
         | profiles | default   |
        And rpmdb does not change

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfED1:s-default"
        And I successfully run "dnf -y module disable ModuleConfED1:s-default"

  Scenario: Installing a module stream with system but no cli profile specification uses empty configured 'default' profile which exists
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfED2:s-default"
       Then a module ModuleConfED2 config file should contain
         | Key      | Value     |
         | enabled  | 1         |
         | stream   | s-default |
         | version  | 1         |
         | profiles | default   |
        And rpmdb does not change

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfED2:s-default"
        And I successfully run "dnf -y module disable ModuleConfED2:s-default"

  Scenario: Installing a module stream with system but no cli profile specification uses configured 'alt' profile which exists
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfED3:s-alt"
       Then a module ModuleConfED3 config file should contain
         | Key      | Value |
         | enabled  | 1     |
         | stream   | s-alt |
         | version  | 1     |
         | profiles | alt   |
        And rpmdb changes are
         | State     | Packages                   |
         | installed | TestConfALT/1-1.modConfED3 | 

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfED3:s-alt"
        And I successfully run "dnf -y module disable ModuleConfED3:s-alt"

  @xfail
  # https://bugzilla.redhat.com/show_bug.cgi?id=1568165
  Scenario: Installing a module stream with no system and no cli profile specification uses empty 'default' profile which does not exist
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfND1:s-default"
       Then a module ModuleConfND1 config file should contain
         | Key      | Value     |
         | enabled  | 1         |
         | stream   | s-default |
         | version  | 1         |
         | profiles | default   |
        And rpmdb does not change

  @xfail
  # due to previous scenario failure
  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfND1:s-default"
        And I successfully run "dnf -y module disable ModuleConfND1:s-default"

  @xfail
  # https://bugzilla.redhat.com/show_bug.cgi?id=1568165
  Scenario: Installing a module stream with system but no cli profile specification uses empty configured 'default' profile which does not exist
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfND2:s-default"
       Then a module ModuleConfND2 config file should contain
         | Key      | Value     |
         | enabled  | 1         |
         | stream   | s-default |
         | version  | 1         |
         | profiles | default   |
        And rpmdb does not change

  @xfail
  # due to previous scenario failure
  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfND2:s-default"
        And I successfully run "dnf -y module disable ModuleConfND2:s-default"

  Scenario: Installing a module stream with system but no cli profile specification uses configured 'alt' profile which exists
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleConfND3:s-alt"
       Then a module ModuleConfND3 config file should contain
         | Key      | Value |
         | enabled  | 1     |
         | stream   | s-alt |
         | version  | 1     |
         | profiles | alt   |
        And rpmdb changes are
         | State     | Packages                   |
         | installed | TestConfALT/1-1.modConfND3 | 

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleConfND3:s-alt"
        And I successfully run "dnf -y module disable ModuleConfND3:s-alt"

