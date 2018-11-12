Feature: Enable module stream with modular dependencies

  @setup
  Scenario: Repository Setup
      Given a file "/etc/dnf/modules.defaults.d/ModuleM.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleM
            stream: f26
            profiles:
              f26: [default]
          """
        And I run steps from file "modularity-repo-4.setup"
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  Scenario: When a module profile is enabled, its modular dependencies are automatically enabled
       When I successfully run "dnf -y module enable ModuleM:f27/default"
       Then the command stdout should match regexp "Enabling module streams:"
        And the command stdout should match regexp "ModuleM +f27"
        And the command stdout should match regexp "ModuleMY +f27"
      
  @xfail @bz1647804
  Scenario: When a module stream is disabled, module streams dependent on it are automatically disabled
       When I successfully run "dnf -y module disable ModuleMY:f27"
       Then the command stdout should match regexp "Disabling module streams:"
        And the command stdout should match regexp "ModuleMY +f27"
        And the command stdout should match regexp "ModuleM +f27"

  Scenario: When a default module stream is enabled, its modular dependencies are automatically enabled
       # reset: just ensure that ModuleM:f27, ModuleMY:f27 are not enabled
       When I successfully run "dnf -y module reset ModuleM:f27"
        And I successfully run "dnf -y module reset ModuleMY:f27"
        And I successfully run "dnf -y module enable ModuleM"
       Then the command stdout should match regexp "Enabling module streams:"
        And the command stdout should match regexp "ModuleM +f26"
        And the command stdout should match regexp "ModuleMX +f26"

  @xfail @bz1648839
  Scenario: Enablement of a different stream of enabled module switches to the new stream and switches all its dependencies
       When I successfully run "dnf -y module reset ModuleM:f26"
        And I successfully run "dnf -y module reset ModuleMX:f26"
        And I successfully run "dnf -y module enable ModuleMZ:f27"
       Then the command stdout should match regexp "Enabling module streams:"
        And the command stdout should match regexp "ModuleMZ +f27"
        And the command stdout should match regexp "ModuleM +f27"
        And the command stdout should match regexp "ModuleMY +f27"
       When I successfully run "dnf -y module enable ModuleMZ:f26"
       Then the command stdout should match regexp "Switching module streams:"
        And the command stdout should match regexp "ModuleMZ +f27 -> f26"
        And the command stdout should match regexp "ModuleM +f27 -> f26"
        And the command stdout should match regexp "Enabling module streams:"
        And the command stdout should match regexp "ModuleMX +f26"

  @xfail @bz1648882
  Scenario: When a disabled module stream is enabled, its modular dependencies are automatically enabled
       When I successfully run "dnf -y module disable ModuleMZ:f26"
        And I successfully run "dnf -y module disable ModuleM:f26"
        And I successfully run "dnf -y module enable ModuleMZ:f26"
       Then the command stdout should match regexp "Enabling module streams:"
        And the command stdout should match regexp "ModuleM +f26"
        And the command stdout should match regexp "ModuleMX +f26"
        And the command stdout should match regexp "ModuleMZ +f26"
