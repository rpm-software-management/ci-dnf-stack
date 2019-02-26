Feature: Reset modules

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

  Scenario: I can reset a disabled default stream back to its default state
       When I successfully run "dnf -y module disable ModuleM"
        And I successfully run "dnf module list ModuleM"
       Then the command stdout should match regexp "ModuleM +f26 \[d\]\[x\]"
        And the command stdout should match regexp "ModuleM +f27 \[x\]"
       When I successfully run "dnf -y module reset ModuleM"
       Then the command stdout should match regexp "Resetting modules:"
        And the command stdout should match regexp "ModuleM"
       When I successfully run "dnf module list ModuleM"
       Then the command stdout should match regexp "ModuleM +f26 \[d\]"
        And the command stdout should match regexp "ModuleM +f27"

  Scenario: I can reset a disabled non-default stream back to a non-default state
       When I successfully run "dnf -y module disable ModuleMZ"
        And I successfully run "dnf module list ModuleMZ"
       Then the command stdout should match regexp "ModuleMZ +f26 \[x\]"
        And the command stdout should match regexp "ModuleMZ +f27 \[x\]"
       When I successfully run "dnf -y module reset ModuleMZ"
       Then the command stdout should match regexp "Resetting modules:"
        And the command stdout should match regexp "ModuleMZ"
       When I successfully run "dnf module list ModuleMZ"
       Then the command stdout should match regexp "ModuleMZ +f26"
        And the command stdout should match regexp "ModuleMZ +f27"

  Scenario: Resetting of a default stream does nothing
       When I successfully run "dnf module list ModuleM"
       Then the command stdout should match regexp "ModuleM +f26 \[d\]"
        And the command stdout should match regexp "ModuleM +f27"
       When I successfully run "dnf -y module reset ModuleM"
       Then the command stdout should match regexp "Nothing to do"
       When I successfully run "dnf module list ModuleM"
       Then the command stdout should match regexp "ModuleM +f26 \[d\]"
        And the command stdout should match regexp "ModuleM +f27"

  Scenario: Resetting of a non-default non-enabled stream does nothing
       When I successfully run "dnf module list ModuleMZ"
       Then the command stdout should match regexp "ModuleMZ +f26"
        And the command stdout should match regexp "ModuleMZ +f27"
       When I successfully run "dnf -y module reset ModuleMZ"
       Then the command stdout should match regexp "Nothing to do"
       When I successfully run "dnf module list ModuleMZ"
       Then the command stdout should match regexp "ModuleMZ +f26"
        And the command stdout should match regexp "ModuleMZ +f27"

  @bz1677640
  # scenario different from the one in the relevant requirement!
  Scenario: I can reset an enabled default stream back to its non-enabled default state
       When I successfully run "dnf -y module enable ModuleM:f26"
        And I successfully run "dnf module list ModuleM"
       Then the command stdout should match regexp "ModuleM +f26 \[d\]\[e\]"
        And the command stdout should match regexp "ModuleM +f27"
       When I successfully run "dnf -y module reset ModuleM"
       Then the command stdout should match regexp "Resetting modules:"
        And the command stdout should match regexp "ModuleM"
       When I successfully run "dnf module list ModuleM"
       Then the command stdout should match regexp "ModuleM +f26 \[d\]"
        And the command stdout should match regexp "ModuleM +f27"

  # scenario different from the one in the relevant requirement!
  Scenario: I can reset an enabled non-default stream back to a non-enabled state
       When I successfully run "dnf -y module enable ModuleMZ:f26/default"
        And I successfully run "dnf module list ModuleMZ"
       Then the command stdout should match regexp "ModuleMZ +f26 \[e\]"
        And the command stdout should match regexp "ModuleMZ +f27"
       When I successfully run "dnf -y module reset ModuleMZ"
       Then the command stdout should match regexp "Resetting modules:"
        And the command stdout should match regexp "ModuleMZ"
       When I successfully run "dnf module list ModuleMZ"
       Then the command stdout should match regexp "ModuleMZ +f26"
        And the command stdout should match regexp "ModuleMZ +f27"
