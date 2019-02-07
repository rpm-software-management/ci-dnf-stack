Feature: Installing a disabled module

  @setup
  Scenario: Testing setup
    Given repository "modularity" with packages
         | Package    | Tag     | Value |
         | TestX      | Version | 1     |
         |            | Release | 1     |
      And a file "modules.yaml" with type "modules" added into repository "modularity"
      """
      ---
      data:
        description: Module ModuleX description
        license:
          module: [MIT]
        name: ModuleX
        profiles:
          default:
            rpms: [TestX]
        stream: streamA
        summary: Module ModuleX summary
        version: 1
      document: modulemd
      version: 2
      """
      When I enable repository "modularity"
       And I successfully run "dnf makecache"

  Scenario: I can install a disabled module
      Given I successfully run "dnf -y module disable ModuleX"
       When I save rpmdb
        And I successfully run "dnf -y module install ModuleX:streamA/default"
       Then a module "ModuleX" config file should contain
         | Key      | Value   |
         | profiles | default |
         | state    | enabled |
         | stream   | streamA |
        And rpmdb changes are
          | State     | Packages  |
          | installed | TestX     |
