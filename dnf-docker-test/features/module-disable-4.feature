Feature: Disabling an enabled default stream

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-1.setup"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: f26
            profiles:
              f26: [minimal, devel]
              f27: [minimal]
          """
       When I enable repository "modularityABDE"
        And I successfully run "dnf makecache"

  @bz1613910
  Scenario: It is possible to disable an enabled default stream
       When I run "dnf -y module enable ModuleA"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | f26     |
       When I successfully run "dnf module list ModuleA"
       Then the command stdout should match regexp "ModuleA f26 \[d\]\[e\]"
       When I run "dnf -y module disable ModuleA"
       Then a module ModuleA config file should contain
          | Key     | Value    |
          | state   | disabled |
       When I successfully run "dnf module list ModuleA"
       Then the command stdout should match regexp "ModuleA f26 \[d\]\[x\]"
