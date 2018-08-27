Feature: Installing module profiles

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
        And I run steps from file "modularity-repo-2.setup"
       When I enable repository "modularityABDE"
        And I enable repository "modularityX"
        And I successfully run "dnf makecache"

#  Scenario: I can install a module profile without specifying a profile
#      Given I successfully run "dnf module enable ModuleB:f26"
#       When I successfully run "dnf module install ModuleB"

#  Scenario: I can install a specific module profile
#      Given I successfully run "dnf module enable ModuleA:f26"
#       When I successfully run "dnf module install -y ModuleA/minimal"

#  Scenario: I can install additional module profile
#       When I successfully run "dnf module install --assumeyes ModuleA/client"
#
  Scenario: I can install a module profile for an enabled module stream
      Given I successfully run "dnf module enable ModuleA:f26 -y"
       When I save rpmdb
        And I successfully run "dnf module install -y ModuleA/minimal"
       Then a module "ModuleA" config file should contain
         | Key      | Value |
         | state    | enabled |
         | stream   | f26   |
        And rpmdb changes are
         | State     | Packages       |
         | installed | TestA/1-2.modA |

  Scenario: I can install a module profile by name:stream/profile
      Given I successfully run "dnf module remove -y ModuleA:f26"
       When I save rpmdb
        And I successfully run "dnf module install -y ModuleA:f26/minimal"
       Then a module "ModuleA" config file should contain
         | Key      | Value |
         | state    | enabled |
         | stream   | f26   |
        And rpmdb changes are
         | State     | Packages       |
         | installed | TestA/1-2.modA |

  Scenario: I can install a module profile by name:stream:version/profile
      Given I successfully run "dnf module remove -y ModuleA:f26"
       When I save rpmdb
        And I successfully run "dnf module install -y ModuleA:f26:2/minimal"
       Then a module "ModuleA" config file should contain
         | Key      | Value |
         | state    | enabled |
         | stream   | f26   |
        And rpmdb changes are
         | State     | Packages       |
         | installed | TestA/1-2.modA |

  Scenario: I can install multiple module profiles at the same time
      Given I successfully run "dnf module remove -y ModuleA:f26"
       When I save rpmdb
        And I successfully run "dnf module install -y ModuleA/minimal ModuleA/devel"
       Then a module "ModuleA" config file should contain
         | Key      | Value |
         | state    | enabled |
         | stream   | f26   |
        And rpmdb changes are
         | State     | Packages                       |
         | installed | TestA/1-2.modA, TestD/1-1.modA |

  #bz1609919 
  Scenario: I am given information about which module packages are being installed when installing a module profile
      Given I successfully run "dnf module remove -y ModuleA:f26"
       When I save rpmdb
        And I successfully run "dnf module install -y ModuleA/default"
       Then a module "ModuleA" config file should contain
         | Key      | Value |
         | state    | enabled |
         | stream   | f26   |
        And the command stdout section "Installing module profiles:" should match regexp "ModuleA/default"

  @xfail   # bug 1622599
  Scenario: Installing a module profile with RPMs manually installed previously should do nothing
      Given I successfully run "dnf module remove -y ModuleA:f26"
       When I successfully run "dnf install -y TestA-1-2.modA"
        And I save rpmdb
        And I successfully run "dnf module install -y ModuleA:f26:2/minimal"
       Then a module "ModuleA" config file should contain
         | Key      | Value   |
         | state    | enabled |
         | stream   | f26     |
        And rpmdb does not change
        And the command stdout should match line by line regexp
            """
            ?Last metadata expiration check
            Dependencies resolved.
            Nothing to do.
            Complete!
            """
