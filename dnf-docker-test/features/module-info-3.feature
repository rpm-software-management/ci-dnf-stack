Feature: Module stream context is listed in the module info command output

  @setup
  Scenario: Testing repository and defaults setup
    Given repository "modularity" with packages
         | Package      | Tag      | Value  |
         | modA/TestA   | Version  | 1      |
         |              | Release  | 1      |
      And a file "modules.yaml" with type "modules" added into repository "modularity"
          """
          ---
          data:
            name: ModuleA
            stream: stream1
            version: 1
            context: con1A
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
            name: ModuleA
            stream: stream1
            version: 1
            context: con2A
            summary: Module ModuleA summary
            description: Module ModuleA description
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
            context: con1R
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
            context: con2R
            summary: Module ModuleR summary
            description: Module ModuleA description
            license:
              module: [MIT]
          document: modulemd
          version: 2
          """
      When I enable repository "modularity"
        And I successfully run "dnf makecache"

  @bz1636091
  Scenario: The module stream context information is present
       When I successfully run "dnf module info ModuleR:stream1"
       Then the command stdout should match regexp "Context *: con1R"

  @bz1636337
  Scenario: I can get the module context of the active stream
      Given I successfully run "dnf -y module enable ModuleR:stream2"
        And I successfully run "dnf -y module install ModuleA:stream1"
       When I successfully run "dnf module info ModuleA"
       Then the command stdout should match line by line regexp
       """
       ?Last metadata expiration check.*
       Name        : ModuleA
       Stream      : stream1 \[e\]
       Version     : 1
       Context     : con1A
       Repo        : modularity
       Summary     : Module ModuleA summary
       Description : Module ModuleA description
      
       Name        : ModuleA
       Stream      : stream1 \[e\] \[a\]
       Version     : 1
       Context     : con2A
       Repo        : modularity
       Summary     : Module ModuleA summary
       Description : Module ModuleA description
      
       Hint:
       """
