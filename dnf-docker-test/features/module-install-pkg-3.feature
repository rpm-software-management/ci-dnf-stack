Feature: Installing package when default stream is defined

  @setup
  Scenario: Testing repository Setup
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
        And I run steps from file "modularity-repo-3.setup"
       When I enable repository "modularityY"
        And I enable repository "ursineY"
        And I successfully run "dnf makecache"

  Scenario: a package from a non-enabled module is preferred when default stream is defined
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

  @setup
  Scenario: cleanup from previous scenario
      Given I successfully run "dnf remove TestY -y"
        And I successfully run "dnf module disable ModuleY"

  Scenario: rpm from enabled stream is preferred regardless of NVRs
      Given I successfully run "dnf module enable ModuleY:f27 -y"
       When I save rpmdb
        And I successfully run "dnf install -y TestY"
       Then rpmdb changes are
          | State     | Packages       |
          | installed | TestY/1-2.modY |
