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
       When I successfully run "dnf module disable ModuleB -y"
       Then the command stdout should match regexp "Disabling module streams:"
        And the command stdout should match regexp "ModuleB *f26"
        And a module ModuleB config file should contain
          | Key   | Value    |
          | state | disabled |

  @bz1649261
  Scenario: Inform about unneded information in module spec
       When I successfully run "dnf module disable ModuleB:f26 -y"
       Then the command stdout should match regexp "Only module name required. Ignoring unneeded information in argument: 'ModuleB:f26'"
        And the command stdout should match regexp "Nothing to do."
        And a module ModuleB config file should contain
          | Key   | Value    |
          | state | disabled |

  Scenario: I can disable a module when specifying stream
       When I successfully run "dnf module enable ModuleB:f26 -y"
        And I successfully run "dnf module disable ModuleB:f26 -y"
       Then the command stdout should match regexp "Disabling module streams:"
        And the command stdout should match regexp "ModuleB *f26"
        And a module ModuleB config file should contain
          | Key   | Value    |
          | state | disabled |

  Scenario: I can disable a module when specifying both stream and correct version
       When I successfully run "dnf module enable ModuleB:f26 -y"
        And I successfully run "dnf module disable ModuleB:f26:1 -y"
       Then the command stdout should match regexp "Disabling module streams:"
        And the command stdout should match regexp "ModuleB *f26"
        And a module ModuleB config file should contain
          | Key   | Value    |
          | state | disabled |

  Scenario: Disabling an already disabled module should pass
       When I successfully run "dnf module disable ModuleB:f26 -y"
       Then the command stdout should match regexp "Nothing to do."
        And a module ModuleB config file should contain
          | Key   | Value    |
          | state | disabled |

  Scenario: I can disable a module with installed profile when specifying stream
       When I successfully run "dnf module enable ModuleA:f26 -y"
        And I successfully run "dnf module disable ModuleA:f26 -y"
       Then the command stdout should match regexp "Disabling module streams:"
        And the command stdout should match regexp "ModuleA *f26"
        And a module ModuleA config file should contain
          | Key   | Value    |
          | state | disabled |

  Scenario: I can disable a module with installed profile when specifying both stream and correct version
       When I successfully run "dnf module enable ModuleA:f26 -y"
        And I successfully run "dnf module disable ModuleA:f26:2 -y"
       Then the command stdout should match regexp "Disabling module streams:"
        And the command stdout should match regexp "ModuleA *f26"
        And a module ModuleA config file should contain
          | Key   | Value    |
          | state | disabled |

  Scenario: I can disable a module with installed profile when specifying other valid stream
       When I successfully run "dnf module enable ModuleA:f26 -y"
        And I successfully run "dnf module disable ModuleA:f27 -y"
       Then the command stdout should match regexp "Disabling module streams:"
        And the command stdout should match regexp "ModuleA *f26"
        And a module ModuleA config file should contain
          | Key   | Value    |
          | state | disabled |

