Feature: Dependency resolution must occur to determine the appropriate dependent stream+context to use

  @setup
  Scenario: Testing repository and defaults setup
    Given repository "modularity" with packages
         | Package          | Tag      | Value  |
         | modACon1/TestA a | Version  | 1      |
         |                  | Requires | TestR  |
         | modACon2/TestA b | Version  | 1      |
         |                  | Requires | TestR  |
         | modR/TestR v1    | Version  | 1      |
         | modR/TestR v2    | Version  | 2      |

      And a file "modules.yaml" with type "modules" added into repository "modularity"
          """
          ---
          data:
            name: ModuleA
            stream: stream1
            version: 1
            context: con1
            summary: Module ModuleA summary
            description: Module ModuleA description
            license:
              module: [MIT]
            dependencies:
              - requires:
                  ModuleR: [stream1]
            profiles:
              default:
                rpms: ["TestA"]
            artifacts:
                rpms: ["TestA-0:1-1.modACon1.noarch"]
            components:
              rpms:
                TestA: { rationale: 'TestA package' }
          document: modulemd
          version: 2
          ---
          data:
            name: ModuleA
            stream: stream1
            version: 1
            context: con2
            summary: Module ModuleA summary
            description: Module ModuleA description
            license:
              module: [MIT]
            dependencies:
              - requires:
                  ModuleR: [stream2]
            profiles:
              default:
                rpms: ["TestA"]
            artifacts:
                rpms: ["TestA-0:1-1.modACon2.noarch"]
            components:
              rpms:
                TestA: { rationale: 'TestA package' }
          document: modulemd
          version: 2
          ---
          data:
            name: ModuleR
            stream: stream1
            version: 1
            summary: Module ModuleR summary
            description: Module ModuleR description
            license:
              module: [MIT]
            profiles:
              default:
                rpms: ["TestR"]
            artifacts:
                rpms: ["TestR-0:1-1.modR.noarch"]
            components:
              rpms:
                TestR: { rationale: 'TestR package' }
          document: modulemd
          version: 2
          ---
          data:
            name: ModuleR
            stream: stream2
            version: 1
            summary: Module ModuleR summary
            description: Module ModuleR description
            license:
              module: [MIT]
            profiles:
              default:
                rpms: ["TestR"]
            artifacts:
                rpms: ["TestR-0:2-1.modR.noarch"]
            components:
              rpms:
                TestR: { rationale: 'TestR package' }
          document: modulemd
          version: 2
          """
      When I enable repository "modularity"
        And I successfully run "dnf makecache"

  Scenario: Appropriate context is selected depending on the enabled required module stream
      Given I successfully run "dnf -y module enable ModuleR:stream2"
       When I save rpmdb
        And I run "dnf -y module install ModuleA:stream1/default"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |
        And rpmdb changes are
          | State     | Packages           |
          | installed | TestA/1-1.modACon2,TestR/2-1.modR |
      Given I successfully run "dnf -y module reset ModuleR ModuleA"
        And I successfully run "rpm -e TestA TestR"
        And I successfully run "dnf -y module enable ModuleR:stream1"
       When I save rpmdb
        And I run "dnf -y module install ModuleA:stream1/default"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |
        And rpmdb changes are
          | State     | Packages           |
          | installed | TestA/1-1.modACon1,TestR/1-1.modR |
