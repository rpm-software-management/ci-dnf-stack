Feature: When enabling modules and error should be issued in case of stream conflicts

  @setup
  Scenario: Testing repository and defaults setup
    Given repository "modularity" with packages
         | Package          | Tag      | Value  |
         | foo              | Version  | 1      |

      And a file "modules.yaml" with type "modules" added into repository "modularity"
          """
          ---
          data:
            name: ModuleA
            stream: stream1
            version: 1
            summary: Module ModuleA summary
            description: Module ModuleA description
            license:
              module: [MIT]
            dependencies:
              - requires:
                  ModuleR: [stream1]
          document: modulemd
          version: 2
          ---
          data:
            name: ModuleB
            stream: stream2
            version: 1
            summary: Module ModuleB summary
            description: Module ModuleB description
            license:
              module: [MIT]
            dependencies:
              - requires:
                  ModuleR: [stream2]
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
          document: modulemd
          version: 2
          """
      When I enable repository "modularity"
        And I successfully run "dnf makecache"

  Scenario: Enabling ModuleA and ModuleB both requiring ModuleR but different streams
       When I run "dnf -y module enable ModuleA:stream1 ModuleB:stream2"
       Then the command should fail
        And the command stderr should match regexp "Modular dependency problems:"
        And the command stderr should match regexp "module ModuleR:stream1:1:-0.noarch conflicts with.*ModuleR:stream2:1:-0.noarch"
        And the command stderr should match regexp "conflicting requests"

  @bz1651280
  Scenario: Enabling ModuleR:stream2 and ModuleA requiring ModuleR:stream1
       When I run "dnf -y module enable ModuleA:stream1 ModuleR:stream2"
       Then the command should fail
        And the command stderr should match regexp "Modular dependency problems:"
        And the command stderr should match regexp "module ModuleR:stream1:1:-0.noarch conflicts with.*ModuleR:stream2:1:-0.noarch"
        And the command stderr should match regexp "conflicting requests"
