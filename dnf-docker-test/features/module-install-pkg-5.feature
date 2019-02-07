Feature: RPMs can be installed locally regardless the modular content

  @setup
  Scenario: Testing setup
    Given repository "base" with packages
         | Package    | Tag     | Value |
         | TestA      | Version | 1     |
         |            | Release | 1     |
      And repository "modularity" with packages
         | Package    | Tag     | Value |
         | modA/TestA | Version | 2     |
         |            | Release | 1     |
      And a file "modules.yaml" with type "modules" added into repository "modularity"
      """
      ---
      data:
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
        artifacts:
          rpms: ["TestA-0:2-1.modA.noarch"]
        components:
          rpms:
            TestA: {rationale: 'rationale for TestA'}
      document: modulemd
      version: 2
      """
      When I enable repository "modularity"
       And I successfully run "dnf makecache"

  @bz1582105
  Scenario: Install a local RPM with different package version available in enabled stream
      Given I successfully run "dnf -y module enable ModuleA:streamA"
       When I save rpmdb
        And I successfully run "dnf -y install TestA-1-1.noarch.rpm" in repository "base"
       Then rpmdb changes are
          | State     | Packages  |
	  | installed | TestA/1-1 |

  @bz1582105
  Scenario: Local install RPM that belongs to a disabled module
      Given I successfully run "dnf -y module disable ModuleA"
       When I save rpmdb
        And I successfully run "dnf -y install TestA-2-1.modA.noarch.rpm" in repository "modularity"
       Then rpmdb changes are
          | State     | Packages       |
	  | updated   | TestA/2-1.modA |
