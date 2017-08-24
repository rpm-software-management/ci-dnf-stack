Feature: Basic test for dnf module install

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
        | Package | Tag       | Value |
        | TestA   | Version   | 1     |
        |         | Release   | 1     |
        | TestB   | Version   | 1     |
        |         | Release   | 1     |
        And a file "modules.yaml" with type "modules" added into repository "base"
            """
            ---
            data:
              artifacts:
                rpms: [TestA-1-1.noarch, TestB-1-1.noarch]
              components:
                rpms:
                  TestA: {rationale: ''}
                  TestB: {rationale: ''}
              dependencies:
                buildrequires: {}
                requires: {}
              description: Test module
              license:
                module: [MIT]
              name: testmodule
              profiles:
                default:
                  rpms: [TestA, TestB]
                minimal:
                  rpms: [TestA]
              stream: f26
              summary: Test module
              version: 1
            document: modulemd
            version: 1

            """

  Scenario: dnf module install
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y module enable testmodule:f26"
        And I successfully run "dnf -y module install testmodule/default"
       Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |
