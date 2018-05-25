Feature: Updating module profiles and default streams

  @setup
  Scenario: Testing repository Setup
      Given repository "modularityAB" with packages
          | Package       | Tag      | Value |
          | modA/TestA    | Version  | 1     |
          |               | Release  | 1     |
          | modA/TestA v2 | Version  | 2     |
          |               | Release  | 1     |
          |               | Requires | TestC |
          | modB/TestB    | Version  | 1     |
          |               | Release  | 1     |
          |               | Requires | TestD |
          | TestC         | Version  | 1     |
          |               | Release  | 1     |
          | TestD         | Version  | 1     |
          |               | Release  | 1     |
        And a file "modules.yaml" with type "modules" added into repository "modularityAB"
        """
        ---
        data:
          name: ModuleA
          stream: f26
          version: 1
          summary: Module ModuleA summary
          description: Module ModuleA description
          license:
            module: [MIT]
          profiles:
            default:
              rpms: [TestA]
          artifacts:
            rpms: ["TestA-0:1-1.modA.noarch"]
          components:
            rpms:
              TestA: {rationale: 'rationale for TestA'}
        document: modulemd
        version: 2
        ---
        data:
          name: ModuleA
          stream: f26
          version: 2
          summary: Module ModuleA summary
          description: Module ModuleA description
          license:
            module: [MIT]
          dependencies:
            - requires:
                ModuleB: []
          profiles:
            default:
              rpms: [TestA]
          artifacts:
            rpms: ["TestA-0:2-1.modA.noarch"]
          components:
            rpms:
              TestA: {rationale: 'rationale for TestA'}
        document: modulemd
        version: 2
        ---
        data:
          name: ModuleB
          stream: f26
          version: 1
          summary: Module ModuleB summary
          description: Module ModuleB description
          license:
            module: [MIT]
          profiles:
            minimal:
              rpms: [TestB]
          artifacts:
            rpms: ["TestB-0:1-1.modB.noarch"]
          components:
            rpms:
              TestB: {rationale: 'rationale for TestB'}
        document: modulemd
        version: 2
        """
        And a file "/etc/dnf/modules.defaults.d/ModuleB.yaml" with
        """
        document: modulemd-defaults
        version: 1
        data:
          module: ModuleB
          stream: f26
          profiles:
            f26: [minimal]
        """
       When I enable repository "modularityAB"
        And I successfully run "dnf module enable ModuleA:f26 -y"
        And I successfully run "dnf makecache"

  # https://bugzilla.redhat.com/show_bug.cgi?id=1582546
  @xfail
  Scenario: default stream is used for new deps during an update
      Given I successfully run "dnf module install ModuleA:f26:1 -y"
       When I save rpmdb
        And I successfully run "dnf module update ModuleA -y"
       Then a module ModuleB config file should contain
          | Key     | Value         |
          | enabled | 1             |
          | stream  | (set) minimal |
          | version | 1             |
        And a module ModuleA config file should contain
          | Key     | Value |
          | version | 2     |
          | stream  | f26   |
        And rpmdb changes are
          | State     | Packages                             |
          | updated   | TestA/2-1.modA                       |
          | installed | TestB/1-1.modB, TestC/1-1, TestD/1-1 |
