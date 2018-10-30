@jiraRHELPLAN-6073
Feature: Filter RPMs by enabled and default module streams

  @setup
  Scenario: setup
    Given repository "ModularRepo" with packages
         | Package       | Tag      | Value |
         | modA/TestA    | Version  | 1     |
         |               | Release  | 1     |
         | modA/TestA v2 | Version  | 2     |
         |               | Release  | 1     |
         | modA/TestA v3 | Version  | 3     |
         |               | Release  | 1     |
         | modB/TestB    | Version  | 1     |
         |               | Release  | 1     |
         | modB/TestB v2 | Version  | 2     |
         |               | Release  | 1     |
         | modB/TestB v3 | Version  | 3     |
         |               | Release  | 1     |
         | modC/TestC    | Version  | 1     |
         |               | Release  | 1     |
         | modC/TestC v2 | Version  | 2     |
         |               | Release  | 1     |
         | modC/TestC v3 | Version  | 3     |
         |               | Release  | 1     |
         | modC/TestD    | Version  | 1     |
         |               | Release  | 1     |
         | modD/TestD v2 | Version  | 2     |
         |               | Release  | 1     |
         | modD/TestD v3 | Version  | 3     |
         |               | Release  | 1     |
      And repository "RegularRepo" with packages
         | Package       | Tag      | Value |
         | TestA         | Version  | 1     |
         |               | Release  | 2     |
         | TestB         | Version  | 1     |
         |               | Release  | 2     |
         | TestC         | Version  | 1     |
         |               | Release  | 2     |
         | TestD         | Version  | 1     |
         |               | Release  | 2     |
      And a file "modules.yaml" with type "modules" added into repository "ModularRepo"
          """
          ---
          data:
            artifacts:
              rpms: ["TestA-0:1-1.modA.noarch"]
            components:
              rpms:
                TestA: {rationale: 'rationale for TestA'}
            description: Module ModuleA description
            license:
              module: [MIT]
            name: ModuleA
            profiles:
              default:
                rpms: [TestA]
            stream: streamA
            summary: Module ModuleA summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestA-0:2-1.modA.noarch"]
            components:
              rpms:
                TestA: {rationale: 'rationale for TestA'}
            description: Module ModuleA description
            license:
              module: [MIT]
            name: ModuleA
            profiles:
              default:
                rpms: [TestA]
            stream: streamB
            summary: Module ModuleA summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestA-0:3-1.modA.noarch"]
            components:
              rpms:
                TestA: {rationale: 'rationale for TestA'}
            description: Module ModuleA description
            license:
              module: [MIT]
            name: ModuleA
            profiles:
              default:
                rpms: [TestA]
            stream: streamC
            summary: Module ModuleA summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestB-0:1-1.modB.noarch"]
            components:
              rpms:
                TestB: {rationale: 'rationale for TestB'}
            description: Module ModuleB description
            license:
              module: [MIT]
            name: ModuleB
            profiles:
              default:
                rpms: [TestB]
            stream: streamA
            summary: Module ModuleB summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestB-0:2-1.modB.noarch"]
            components:
              rpms:
                TestB: {rationale: 'rationale for TestB'}
            description: Module ModuleB description
            license:
              module: [MIT]
            name: ModuleB
            profiles:
              default:
                rpms: [TestB]
            stream: streamB
            summary: Module ModuleB summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestB-0:3-1.modB.noarch"]
            components:
              rpms:
                TestB: {rationale: 'rationale for TestB'}
            description: Module ModuleB description
            license:
              module: [MIT]
            name: ModuleB
            profiles:
              default:
                rpms: [TestB]
            stream: streamC
            summary: Module ModuleB summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestC-0:1-1.modC.noarch"]
            components:
              rpms:
                TestC: {rationale: 'rationale for TestC'}
            description: Module ModuleC description
            license:
              module: [MIT]
            name: ModuleC
            profiles:
              default:
                rpms: [TestC]
            stream: streamA
            summary: Module ModuleC summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestC-0:2-1.modC.noarch"]
            components:
              rpms:
                TestC: {rationale: 'rationale for TestC'}
            description: Module ModuleC description
            license:
              module: [MIT]
            name: ModuleC
            profiles:
              default:
                rpms: [TestC]
            stream: streamB
            summary: Module ModuleC summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestC-0:3-1.modC.noarch"]
            components:
              rpms:
                TestC: {rationale: 'rationale for TestC'}
            description: Module ModuleC description
            license:
              module: [MIT]
            name: ModuleC
            profiles:
              default:
                rpms: [TestC]
            stream: streamC
            summary: Module ModuleC summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestD-0:1-1.modD.noarch"]
            components:
              rpms:
                TestD: {rationale: 'rationale for TestD'}
            description: Module ModuleD description
            license:
              module: [MIT]
            name: ModuleD
            profiles:
              default:
                rpms: [TestD]
            stream: streamA
            summary: Module ModuleD summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestD-0:2-1.modD.noarch"]
            components:
              rpms:
                TestD: {rationale: 'rationale for TestD'}
            description: Module ModuleD description
            license:
              module: [MIT]
            name: ModuleD
            profiles:
              default:
                rpms: [TestD]
            stream: streamB
            summary: Module ModuleD summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestD-0:3-1.modD.noarch"]
            components:
              rpms:
                TestD: {rationale: 'rationale for TestD'}
            description: Module ModuleD description
            license:
              module: [MIT]
            name: ModuleD
            profiles:
              default:
                rpms: [TestD]
            stream: streamC
            summary: Module ModuleD summary
            version: 1
          document: modulemd
          version: 2
          ...
          ---
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: streamA
            profiles:
              streamA: [default]
              streamB: [default]
              streamC: [default]
          ...
          ---
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleB
            stream: streamA
            profiles:
              streamA: [default]
              streamB: [default]
              streamC: [default]
          ...
          ---
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleC
            stream: streamC
            profiles:
              streamA: [default]
              streamB: [default]
              streamC: [default]
          """
     When I enable repository "ModularRepo"
      And I enable repository "RegularRepo"
     Then I successfully run "dnf makecache"
      And I successfully run "dnf module enable -y ModuleB:streamB"
      And I successfully run "dnf module disable -y ModuleC"

  Scenario: RPMs are filtered by enabled module stream
       When I save rpmdb
        And I successfully run "dnf -y install TestA TestB TestC TestD"
       Then rpmdb changes are
           | State     | Packages                                             |
           | installed | TestA/1-1.modA, TestB/2-1.modB, TestC/1-2, TestD/1-2 |
