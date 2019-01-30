Feature: Install a module with modular dependencies

  @setup
  Scenario: Testing module modular dependency handling (setup)
      Given I run steps from file "modularity-repo-10.setup"
       When I enable repository "modularityX"
        And I enable repository "modularityY"
        And I successfully run "dnf makecache"

  Scenario: Install a module that requires a module, specifying one stream in Requires
       When I successfully run "dnf -y module install ModuleYA:f26/default"
       Then a module ModuleYA config file should contain
           | Key      | Value    |
           | state    | enabled  |
           | stream   | f26      |
        And a module ModuleX config file should contain
           | Key      | Value    |
           | state    | enabled  |
           | stream   | f28      |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleYA"
        And I successfully run "dnf -y module reset ModuleYA"
        And I successfully run "dnf -y module remove ModuleX"
        And I successfully run "dnf -y module reset ModuleX"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1651701
  @bz1651701
  Scenario: Install a module that requires a module, specifying multiple streams in Requires
       When I successfully run "dnf -y module install ModuleYB:f26/default"
       Then a module ModuleYB config file should contain
           | Key      | Value    |
           | state    | enabled  |
           | stream   | f26      |
        And a module ModuleX config file should contain
           | Key      | Value    |
           | state    | enabled  |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleYB"
        And I successfully run "dnf -y module reset ModuleYB"
        And I successfully run "dnf -y module remove ModuleX"
        And I successfully run "dnf -y module reset ModuleX"

  Scenario: Install a module that requires a module, not specifying any stream in Requires
       When I successfully run "dnf -y module install ModuleYC:f26/default"
       Then a module ModuleYC config file should contain
           | Key      | Value    |
           | state    | enabled  |
           | stream   | f26      |
        And a module ModuleX config file should contain
           | Key      | Value    |
           | state    | enabled  |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleYC"
        And I successfully run "dnf -y module reset ModuleYC"
        And I successfully run "dnf -y module remove ModuleX"
        And I successfully run "dnf -y module reset ModuleX"

  Scenario: Install a module that requires a module, excluding one stream in Requires
       When I successfully run "dnf -y module install ModuleYD:f26/default"
       Then a module ModuleYD config file should contain
           | Key      | Value    |
           | state    | enabled  |
           | stream   | f26      |
        And a module ModuleX config file should contain
           | Key      | Value    |
           | state    | enabled  |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleYD"
        And I successfully run "dnf -y module reset ModuleYD"
        And I successfully run "dnf -y module remove ModuleX"
        And I successfully run "dnf -y module reset ModuleX"

  Scenario: Install a module that requires a module, excluding multiple streams in Requires
       When I successfully run "dnf -y module install ModuleYE:f26/default"
       Then a module ModuleYE config file should contain
           | Key      | Value    |
           | state    | enabled  |
           | stream   | f26      |
        And a module ModuleX config file should contain
           | Key      | Value    |
           | state    | enabled  |
           | stream   | f28      |

  Scenario: Cleanup from previous scenario
       When I successfully run "dnf -y module remove ModuleYE"
        And I successfully run "dnf -y module reset ModuleYE"
        And I successfully run "dnf -y module remove ModuleX"
        And I successfully run "dnf -y module reset ModuleX"

  Scenario: Install a module that requires a module, excluding all of the streams in Requires
       When I run "dnf -y module install ModuleYF:f26/default"
       Then the command should fail
        And the command stderr should match regexp "Problem: module ModuleYF:f26:1:-0.noarch requires module\(ModuleX\), but none of the providers can be installed"

  Scenario: Install a module that requires a module, specifying nonexisting stream in Requires
       When I run "dnf -y module install ModuleYG:f26/default"
       Then the command should fail
        And the command stderr should match regexp "nothing provides module\(ModuleX:nonexistent\) needed by module ModuleYG:f26:1:-0.noarch"

  Scenario: Install a module that requires a module, excluding nonexisting stream in Requires
       When I successfully run "dnf -y module install ModuleYH:f26/default"
       Then a module ModuleYH config file should contain
           | Key      | Value    |
           | state    | enabled  |
           | stream   | f26      |
        And a module ModuleX config file should contain
           | Key      | Value    |
           | state    | enabled  |

