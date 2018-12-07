Feature: Install a module with only non-modular packages

  @setup
  Scenario: Testing setup
    Given repository "base" with packages
         | Package    | Tag     | Value |
         | TestA      | Version | 1     |
         |            | Release | 1     |
      And repository "modularityX" with packages
         | Package    | Tag     | Value |
         | TestX      | Version | 1     |
         |            | Release | 1     |
      And a file "modules.yaml" with type "modules" added into repository "modularityX"
      """
      ---
      data:
        description: Module ModuleX description
        license:
          module: [MIT]
        name: ModuleX
        profiles:
          default:
            rpms: [TestA, TestX]
        stream: streamA
        summary: Module ModuleX summary
        version: 1
      document: modulemd
      version: 2
      """
      When I enable repository "base"
       And I enable repository "modularityX"
       And I successfully run "dnf makecache"

  @bz1592408
  Scenario: Install a module of which all packages are non-modular
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleX:streamA/default"
       Then the command stdout should match regexp "Installing.*packages:"
        And the command stdout should match regexp "TestA.*base"
        And the command stdout should match regexp "TestX.*modularityX"
        And the command stdout should match regexp "Installing module profiles:"
        And the command stdout should match regexp "ModuleX/default"
        And the command stdout should not match regexp "Nothing to install"
        And a module "ModuleX" config file should contain
         | Key      | Value   |
         | profiles | default |
         | state    | enabled |
         | stream   | streamA |
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestA, TestX |
       When I successfully run "dnf module list ModuleX"
       Then the command stdout should match regexp "ModuleX +streamA \[e\] +default \[i\]"
