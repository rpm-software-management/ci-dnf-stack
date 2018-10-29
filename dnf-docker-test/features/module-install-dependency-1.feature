Feature: Install a module with non-modular dependencies

  @setup
  Scenario: Testing module non-modular dependency handling (setup)
      Given I run steps from file "modularity-repo-6.setup"
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"
        And I successfully run "dnf -y module enable ModuleM:f26"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1618421
  Scenario: Try to install a module with modular dependency that requires non-modular package that is not available
       When I save rpmdb
        And I run "dnf -y module install ModuleM/default"
       Then the command should fail
        And the command stderr should match regexp "Problem: package TestMBX-1-1.modM.noarch requires TestMX, but none of the providers can be installed"
        And the command stderr should match regexp "nothing provides TestY needed by TestMX-1-1.modMX.noarch"
        And rpmdb does not change

  # https://bugzilla.redhat.com/show_bug.cgi?id=1618421
  Scenario: Install a module with modular dependency that requires non-modular package that is available
       When I save rpmdb
        And I enable repository "ursineY"
        And I successfully run "dnf -y module install ModuleM/default"
       Then rpmdb changes are
         | State     | Packages |
         | installed | TestMA/1-1.modM, TestMB/1-1.modM, TestMBX/1-1.modM, TestMX/1-1.modMX, TestY |
