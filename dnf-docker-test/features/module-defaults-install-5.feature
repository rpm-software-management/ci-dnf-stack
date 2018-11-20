Feature: Filter RPMs by enabled and default module streams

  @setup
  Scenario: setup
    Given repository "ModularRepo" with packages
         | Package       | Tag      | Value |
         | modA/TestA    | Version  | 1     |
         |               | Release  | 1     |
	 |               | Requires | TestB |
         | modB/TestB    | Version  | 1     |
         |               | Release  | 1     |
         | modC/TestC    | Version  | 1     |
         |               | Release  | 1     |
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
            stream: stream1
            dependencies:
              - requires:
                  ModuleB: ["stream1"]
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
            stream: stream1
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
            stream: stream1
            summary: Module ModuleC summary
            version: 1
          document: modulemd
          version: 2
          ...
          ---
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleB
            stream: stream1
            profiles:
              stream1: [default]
          """
     When I enable repository "ModularRepo"
     Then I successfully run "dnf makecache"

  Scenario: Installing a stream without a defined default profile enables the stream
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleC:stream1"
       Then rpmdb does not change
        And a module ModuleC config file should contain
	   | Key      | Value   |
           | state    | enabled |
           | stream   | stream1 |
           | profiles |         |

  Scenario: Installing a stream without a defined default profile enables the stream and its requires
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleA:stream1"
       Then rpmdb does not change
        And a module ModuleA config file should contain
	   | Key      | Value   |
           | state    | enabled |
           | stream   | stream1 |
           | profiles |         |
        And a module ModuleB config file should contain
	   | Key      | Value   |
           | state    | enabled |
           | stream   | stream1 |
           | profiles |         |
