@bz1580455
Feature: Module requires without a specified stream are handled properly

  @setup
  Scenario: Testing repository and defaults setup
    Given repository "modularity" with packages
         | Package     | Tag      | Value  |
         | modA/TestA  | Version  | 1      |
         |             | Release  | 1      |
         |             | Requires | TestB  |
         | modB/TestB  | Version  | 1      |
         |             | Release  | 1      |
         | modC/TestC  | Version  | 1      |
         |             | Release  | 1      |
         |             | Requires | TestD  |
         | modD/TestD  | Version  | 1      |
         |             | Release  | 1      |

      And a file "modules.yaml" with type "modules" added into repository "modularity"
          """
          ---
          data:
            artifacts:
              rpms: ["TestA-0:1-1.noarch"]
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
            stream: myStream
            dependencies:
              - requires:
                  ModuleB: []
            summary: Module ModuleA summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestB-0:1-1.noarch"]
            components:
              rpms:
                TestB: {rationale: 'rationale for TestB'}
            description: Module ModuleX description
            license:
              module: [MIT]
            name: ModuleB
            profiles:
              default:
                rpms: [TestB]
            stream: myStream
            summary: Module ModuleB summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestC-0:1-1.noarch"]
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
            stream: myStream
            dependencies:
              - requires:
                  ModuleD: []
            summary: Module ModuleC summary
            version: 1
          document: modulemd
          version: 2
          ---
          data:
            artifacts:
              rpms: ["TestD-0:1-1.noarch"]
            components:
              rpms:
                TestD: {rationale: 'rationale for TestD'}
            description: Module ModuleX description
            license:
              module: [MIT]
            name: ModuleD
            profiles:
              default:
                rpms: [TestD]
            stream: otherStream
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
            stream: myStream
            profiles:
              myStream: [default]
          ...
          ---
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleB
            stream: myStream
            profiles:
              myStream: [default]
          ...
          ---
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleC
            stream: myStream
            profiles:
              myStream: [default]
          """
       When I enable repository "modularity"
        And I successfully run "dnf makecache"

  Scenario: A default stream for the required module is chosen
       When I successfully run "dnf -y module enable ModuleA"
       Then a module ModuleA config file should contain
          | Key     | Value    |
          | state   | enabled  |
          | stream  | myStream |
        And a module ModuleB config file should contain
          | Key     | Value    |
          | state   | enabled  |
          | stream  | myStream |

  Scenario: Any stream for the required module is chosen when there are no defaults
       When I successfully run "dnf -y module enable ModuleC"
       Then a module ModuleC config file should contain
          | Key     | Value    |
          | state   | enabled  |
          | stream  | myStream |
        And a module ModuleD config file should contain
          | Key     | Value    |
          | state   | enabled  |
          | stream  | otherStream |
