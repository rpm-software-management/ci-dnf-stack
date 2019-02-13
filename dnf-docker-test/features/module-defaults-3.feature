Feature: Default non-enabled streams can be overridden by dependency requests

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
         | modMX/TestMX | Version  | 1      |
         |              | Release  | 1      |
         | modMY/TestMY | Version  | 1      |
         |              | Release  | 1      |
         |              | Requires | TestMB |
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
            artifacts:
              rpms: ["TestMA-0:1-1.modM.noarch", "TestMC-0:1-1.modM.noarch" ]
            components:
              rpms:
                TestMA: {rationale: 'rationale for TestMA'}
                TestMC: {rationale: 'rationale for TestMC'}
          document: modulemd
          version: 2
          ---
          data:
            name: ModuleMX
            stream: streamA
            version: 1
            summary: Module ModuleMX summary
            description: Module ModuleMX description
            license:
              module: [MIT]
            dependencies:
              - requires:
                  ModuleM: [streamA]
            profiles:
              default:
                rpms: [TestMX]
            artifacts:
              rpms: ["TestMX-0:1-1.modMX.noarch"]
            components:
              rpms:
                TestMX: {rationale: 'rationale for TestMX'}
          document: modulemd
          version: 2
          ---
          data:
            name: ModuleMY
            stream: streamB
            version: 1
            summary: Module ModuleMY summary
            description: Module ModuleMY description
            license:
              module: [MIT]
            dependencies:
              - requires:
                  ModuleM: [streamA]
            profiles:
              default:
                rpms: [TestMY]
            artifacts:
              rpms: ["TestMY-0:1-1.modMY.noarch"]
            components:
              rpms:
                TestMY: {rationale: 'rationale for TestMY'}
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
          """
       When I enable repository "modularityM"
        And I successfully run "dnf makecache"

  @bz1648839
  Scenario: A non-default stream is enabled when enabling another stream that requires it
       When I run "dnf -y module enable ModuleMX:streamA"
       Then a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamA |
        And a module ModuleMX config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamA |
       # cleanup
        And I successfully run "dnf -y module reset ModuleM ModuleMX"

  @bz1648839
  Scenario: A non-default stream is enabled when installing another stream that requires it
       When I save rpmdb
        And I run "dnf -y module install ModuleMY:streamB/default"
       Then rpmdb changes are
          | State     | Packages         |
          | installed | TestMY, TestMB   |
        And a module ModuleM config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamA |
        And a module ModuleMY config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | streamB |
          | profiles| default |
       When I successfully run "dnf module list ModuleM"
       Then the command stdout should not match regexp "ModuleM +streamA.*\[i\]"
       # cleanup
        And I successfully run "dnf -y module reset ModuleM ModuleMY"
        And I successfully run "dnf -y remove TestMB TestMY"
