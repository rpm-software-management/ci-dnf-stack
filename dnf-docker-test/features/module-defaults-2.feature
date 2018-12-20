Feature: Default streams are properly switched to enabled

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-9.setup"
        And a file "/etc/dnf/modules.defaults.d/ModuleM.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleM
            stream: streamB
            profiles:
              streamA: [default]
              streamB: [default]
          """
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  @bz1657213
  Scenario: The default stream is enabled when requiring module is enabled
       When I run "dnf -y module enable ModuleMZ:streamA"
       Then a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamB |
        And a module ModuleMZ config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamA |
        And I successfully run "dnf module list ModuleM"
       Then the command stdout should not match regexp "ModuleM +streamB.*\[i\]"
        And I successfully run "dnf module list ModuleMZ"
       Then the command stdout should not match regexp "ModuleMZ +streamA.*\[i\]"
       # cleanup
        And I successfully run "dnf -y module reset ModuleM ModuleMZ"

  Scenario: The default stream is enabled when its package is required by installed package of another module (no module deps)
       When I save rpmdb
        And I run "dnf -y module enable ModuleMZ:streamB"
        And I run "dnf -y install TestMZB"
       Then rpmdb changes are
          | State     | Packages         |
          | installed | TestMZB, TestMA  |
        And a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamB |
        And a module ModuleMZ config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamB |
        And I successfully run "dnf module list ModuleM"
       Then the command stdout should not match regexp "ModuleM +streamB.*\[i\]"
        And I successfully run "dnf module list ModuleMZ"
       Then the command stdout should not match regexp "ModuleMZ +streamB.*\[i\]"
       # cleanup
        And I successfully run "dnf -y remove TestMZB TestMA"
        And I successfully run "dnf -y module reset ModuleM ModuleMZ"

  Scenario: The default stream is enabled when its package is required by installed package of another module (module deps set)
       When I save rpmdb
        And I run "dnf -y module enable ModuleMZ:streamC"
        And I run "dnf -y module reset ModuleM"
        And I run "dnf -y install TestMZC"
       Then rpmdb changes are
          | State     | Packages         |
          | installed | TestMZC, TestMA  |
        And a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamB |
        And a module ModuleMZ config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamC |
        And I successfully run "dnf module list ModuleM"
       Then the command stdout should not match regexp "ModuleM +streamB.*\[i\]"
        And I successfully run "dnf module list ModuleMZ"
       Then the command stdout should not match regexp "ModuleMZ +streamC.*\[i\]"
       # cleanup
        And I successfully run "dnf -y remove TestMZC TestMA"
        And I successfully run "dnf -y module reset ModuleM ModuleMZ"

  Scenario: The default stream is enabled when its package is required by installed non-modular package
       When I enable repository "base"
        And I save rpmdb
        And I run "dnf -y install TestA"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestA, TestMA  |
        And a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamB |
        And I successfully run "dnf module list ModuleM"
       Then the command stdout should not match regexp "ModuleM +streamB.*\[i\]"
       # cleanup
        And I successfully run "dnf -y remove TestA TestMA"
        And I successfully run "dnf -y module reset ModuleM"
