Feature: Non-default profiles can be installed when explicitly specified on command line

  @setup
  Scenario: Testing repository and defaults setup
    Given repository "modularityM" with packages
         | Package      | Tag      | Value  |
         | modM/TestMA  | Version  | 1      |
         |              | Release  | 1      |
         | modM/TestMB  | Version  | 1      |
         |              | Release  | 1      |
         | modM/TestMC  | Version  | 1      |
         |              | Release  | 1      |
      And a file "modules.yaml" with type "modules" added into repository "modularityM"
          """
          ---
          data:
            name: ModuleM
            stream: streamA
            version: 1
            summary: Module ModuleM summary
            description: Module ModuleM description
            license:
              module: [MIT]
            profiles:
              default:
                rpms: [TestMA, TestMB ]
              minimal:
                rpms: [TestMA ]
            artifacts:
              rpms: ["TestMA-0:1-1.modM.noarch", "TestMB-0:1-1.modM.noarch"]
            components:
              rpms:
                TestMA: {rationale: 'rationale for TestMA'}
                TestMB: {rationale: 'rationale for TestMB'}
          document: modulemd
          version: 2
          ---
          data:
            name: ModuleM
            stream: streamB
            version: 1
            summary: Module ModuleM summary
            description: Module ModuleM description
            license:
              module: [MIT]
            profiles:
              default:
                rpms: [TestMA, TestMC]
              minimal:
                rpms: [TestMC ]
            artifacts:
              rpms: ["TestMA-0:1-1.modM.noarch", "TestMC-0:1-1.modM.noarch" ]
            components:
              rpms:
                TestMA: {rationale: 'rationale for TestMA'}
                TestMC: {rationale: 'rationale for TestMC'}
          document: modulemd
          version: 2
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleM.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleM
            stream: streamB
            profiles:
              streamB: [default]
              streamA: [default]
          """
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  Scenario: I can install a non-default profile using dnf module install module:stream/profile
       When I save rpmdb
        And I run "dnf -y module install ModuleM:streamA/minimal"
       Then rpmdb changes are
          | State     | Packages|
          | installed | TestMA  |
        And a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamA |
          | profiles| minimal |
       # cleanup
        And I successfully run "dnf -y module reset ModuleM"
        And I successfully run "dnf -y remove TestMA"

  @bz1573831
  Scenario: I can install a non-default profile from a default stream using dnf module install module/profile
       When I save rpmdb
        And I run "dnf -y module install ModuleM/minimal"
       Then rpmdb changes are
          | State     | Packages|
          | installed | TestMC  |
        And a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamB |
          | profiles| minimal |
       # cleanup
        And I successfully run "dnf -y module reset ModuleM"
        And I successfully run "dnf -y remove TestMC"

  Scenario: I can install a non-default profile from an enabled stream using dnf module install module/profile
       When I save rpmdb
        And I successfully run "dnf -y module enable ModuleM:streamA"
        And I run "dnf -y module install ModuleM/minimal"
       Then rpmdb changes are
          | State     | Packages|
          | installed | TestMA  |
        And a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamA |
          | profiles| minimal |
       # cleanup
        And I successfully run "dnf -y module reset ModuleM"
        And I successfully run "dnf -y remove TestMA"
