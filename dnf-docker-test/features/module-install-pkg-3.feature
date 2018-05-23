Feature: Installing package when default stream is defined

  @setup
  Scenario: Testing repository Setup
      Given I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityY"
        And I successfully run "dnf makecache"

  Scenario: I can install a specific package from a module not enabled when default stream is defined
      Given a file "/etc/dnf/modules.defaults.d/ModuleY.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleY
            stream: f26
            profiles:
              f26: [default]
          """
       When I save rpmdb
        And I successfully run "dnf install -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestY/1-1.modY |
        And a module ModuleY config file should contain
          | Key     | Value |
          | version | -1    |
          | enabled | 1     |
          | stream  | f26   |
