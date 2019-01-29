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
      
#  @xfail @bz1647804
#  Scenario: When a module stream is disabled, module streams dependent on it are automatically disabled
#       When I successfully run "dnf -y module disable ModuleMY:f27"
#       Then the command stdout should match regexp "Disabling module streams:"
#        And the command stdout should match regexp "ModuleMY +f27"
#        And the command stdout should match regexp "ModuleM +f27"
# following scenario is the opposite of the above, matching current bahavior
  Scenario: Module cannot be disabled if there are other enabled streams requiring it
       When I run "dnf -y module disable ModuleMY:f27"
       Then the command should fail
        And the command stderr should match regexp "Error: Problems in request:"
        And the command stderr should match regexp "Modular dependency problems:"
        And the command stderr should match regexp "Problem: module ModuleM:f27:1:-0.noarch requires module\(ModuleMY:f27\)"
        And a module ModuleMY config file should contain
           | Key    | Value   |
           | state  | enabled |
           | stream | f27     |

  Scenario: When a default module stream is enabled, its modular dependencies are automatically enabled
       # reset: just ensure that ModuleM:f27, ModuleMY:f27 are not enabled
      Given I successfully run "dnf -y module reset ModuleM:f27"
        And I successfully run "dnf -y module reset ModuleMY:f27"
       When I successfully run "dnf -y module enable ModuleM"
       Then the command stdout should match regexp "Enabling module streams:"
        And the command stdout should match regexp "ModuleM +f26"
        And the command stdout should match regexp "ModuleMX +f26"

#  @xfail @bz1648882
#  Scenario: When a disabled module stream is enabled, its modular dependencies are automatically enabled
#       When I successfully run "dnf -y module disable ModuleMZ:f26"
#        And I successfully run "dnf -y module disable ModuleM:f26"
#        And I successfully run "dnf -y module enable ModuleMZ:f26"
#       Then the command stdout should match regexp "Enabling module streams:"
#        And the command stdout should match regexp "ModuleM +f26"
#        And the command stdout should match regexp "ModuleMX +f26"
#        And the command stdout should match regexp "ModuleMZ +f26"
# Following scenario, the opposite of the above, is testing the current and probably desired behavior
Scenario: Cannot enable a stream depending on a disabled module
       Given I successfully run "dnf -y module disable ModuleMZ:f26"
         And I successfully run "dnf -y module disable ModuleM:f26"
        When I run "dnf -y module enable ModuleMZ:f26"
        Then the command should fail
        And the command stderr should match regexp "Error: Problems in request:"
        And the command stderr should match regexp "Modular dependency problems:"
        And the command stderr should match regexp "module ModuleM:f26:1:-0.noarch is disabled"
        And a module ModuleMZ config file should contain
           | Key    | Value    |
           | state  | disabled |
