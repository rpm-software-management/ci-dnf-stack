Feature: Disabling module stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
       When I enable repository "modularityABDE"
        And I successfully run "dnf -y module enable ModuleA:f26"
        And I successfully run "dnf -y module install ModuleA/client"
        And I successfully run "dnf -y module enable ModuleB:f26"
        And I successfully run "dnf makecache"

  Scenario: I can disable a module when specifying module name
       When I successfully run "dnf module disable ModuleB"
       Then the command stdout should match regexp "'ModuleB' is disabled"
        And a module ModuleB config file should contain
          | Key     | Value |
          | enabled | False |

  Scenario: I can disable a module when specifying stream
       When I successfully run "dnf module enable ModuleB:f26"
        And I successfully run "dnf module disable ModuleB:f26"
       Then the command stdout should match regexp "'ModuleB:f26' is disabled"
        And a module ModuleB config file should contain
          | Key     | Value |
          | enabled | False |

  Scenario: I can disable a module when specifying both stream and correct version
       When I successfully run "dnf module enable ModuleB:f26"
        And I successfully run "dnf module disable ModuleB:f26:1"
       Then the command stdout should match regexp "'ModuleB:f26:1' is disabled"
        And a module ModuleB config file should contain
          | Key     | Value |
          | enabled | False |

  Scenario: Disabling an already disabled module should pass
       When I successfully run "dnf module disable ModuleB:f26"
       Then the command stdout should match regexp "'ModuleB:f26' is disabled"
        And a module ModuleB config file should contain
          | Key     | Value |
          | enabled | False |

  # DNF does not remove packages
  @xfail
  Scenario: I can disable a module with installed profile when specifying module name
       When I save rpmdb
        And I successfully run "dnf module disable ModuleA"
       Then the command stdout should match regexp "'ModuleA' is disabled"
        And a module ModuleA config file should contain
          | Key     | Value |
          | enabled | False |
        And rpmdb changes are
          | State   | Packages                       |
          | removed | TestA/1-2.modA, TestB/1-1.modA |

  Scenario: I can disable a module with installed profile when specifying stream
       When I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module disable ModuleA:f26"
       Then the command stdout should match regexp "'ModuleA:f26' is disabled"
        And a module ModuleA config file should contain
          | Key     | Value |
          | enabled | False |

  Scenario: I can disable a module with installed profile when specifying both stream and correct version
       When I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module disable ModuleA:f26:2"
       Then the command stdout should match regexp "'ModuleA:f26:2' is disabled"
        And a module ModuleA config file should contain
          | Key     | Value |
          | enabled | False |

  Scenario: I can disable a module with installed profile when specifying other valid stream
       When I successfully run "dnf module enable ModuleA:f26"
        And I successfully run "dnf module disable ModuleA:f27"
       Then the command stdout should match regexp "'ModuleA:f27' is disabled"
        And a module ModuleA config file should contain
          | Key     | Value |
          | enabled | False |

  # DNF does not remove packages
  @xfail
  Scenario: I can disable a module with installed profile when specifying both valid stream and different existing version
      Given I successfully run "dnf -y module install ModuleB:f26:1/default"
       When I save rpmdb
        And I successfully run "dnf module disable ModuleB:f26:2"
       Then the command stdout should match regexp "'ModuleB:f26:2' is disabled"
        And a module ModuleB config file should contain
          | Key     | Value |
          | enabled | False |
        And rpmdb changes are
          | State   | Packages                       |
          | removed | TestG/1-1.modB, TestH/1-1.modB |
