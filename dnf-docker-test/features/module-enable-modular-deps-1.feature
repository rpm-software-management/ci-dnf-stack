Feature: Default non-enabled streams can be overridden by dependency requests

  @setup
  Scenario: Testing repository and defaults setup
    Given repository "modularity" with packages
         | Package      | Tag      | Value  |
         | modA/TestA   | Version  | 1      |
         |              | Release  | 1      |
         |              | Requires | TestR  |
         | modR/TestR   | Version  | 1      |
         |              | Release  | 1      |
         | modA/TestA v2| Version  | 2      |
         |              | Release  | 1      |
         |              | Requires | TestR  |
         | modR/TestR v | Version  | 2      |
         |              | Release  | 1      |
   
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
            profiles:
              default:
                rpms: ["TestA"]
            artifacts:
                rpms: ["TestA-0:1-1.modA.noarch"]
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
            name: ModuleA
            stream: stream2
            version: 1
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
                rpms: ["TestA-0:2-1.modA.noarch"]
            components:
              rpms:
                TestA: { rationale: 'TestA package' }
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

  Scenario: Enabling a default stream depending on a default stream
      Given a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream1
            profiles:
              stream1: [default]
          """
       When I run "dnf -y module enable ModuleA"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |
        And a module ModuleR config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |

  Scenario: Enabling a default stream depending on a non-default stream
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream2
            profiles:
              stream1: [default]
          """
       When I run "dnf -y module enable ModuleA"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |
        And a module ModuleR config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |

  Scenario: Enabling a non-default stream depending on a non-default stream
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream1
            profiles:
              stream1: [default]
          """
	  When I run "dnf -y module enable ModuleA:stream2"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream2 |
        And a module ModuleR config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream2 |

  Scenario: Enabling a non-default stream depending on a default stream
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream2
            profiles:
              stream1: [default]
          """
	  When I run "dnf -y module enable ModuleA:stream2"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream2 |
        And a module ModuleR config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream2 |

  Scenario: Enabling a disabled stream depending on a default stream
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And I successfully run "dnf -y module disable ModuleA"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream1
            profiles:
              stream1: [default]
          """
	  When I run "dnf -y module enable ModuleA:stream1"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |
        And a module ModuleR config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |

  Scenario: Enabling a disabled stream depending on a non-default stream
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And I successfully run "dnf -y module disable ModuleA"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream1
            profiles:
              stream1: [default]
          """
	  When I run "dnf -y module enable ModuleA:stream2"
       Then a module ModuleA config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream2 |
        And a module ModuleR config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream2 |

  Scenario: Switching a stream depending on another stream should fail
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream1
            profiles:
              stream1: [default]
          """
        And I successfully run "dnf -y module enable ModuleA"
       When I run "dnf -y module enable ModuleA:stream2"
       Then the command should fail
        And the command stderr should match regexp "Problem: conflicting requests"

  Scenario: Enabling a stream depending on other than enabled stream should fail
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream1
            profiles:
              stream1: [default]
          """
        And I successfully run "dnf -y module enable ModuleR"
       When I run "dnf -y module enable ModuleA:stream2"
       Then the command should fail
        And the command stderr should match regexp "Problem: conflicting requests"

  Scenario: Enabling a stream depending on a disabled stream should fail
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream1
            profiles:
              stream1: [default]
          """
        And I successfully run "dnf -y module disable ModuleR"
       When I run "dnf -y module enable ModuleA:stream1"
       Then the command should fail
        And the command stderr should match regexp "Problem: conflicting requests"
        And the command stderr should match regexp "module ModuleR:stream1:1:-0.noarch is disabled"

  @xfail @bz1488089 @bz1653623 # however there is a bug 1669491 requesting the opposite
  Scenario: Switching a stream with installed profile should clear installed profiles
      Given I successfully run "dnf -y module reset ModuleA ModuleR"
        And a file "/etc/dnf/modules.defaults.d/ModuleA.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleA
            stream: stream1
            profiles:
              stream1: [default]
          """
        And a file "/etc/dnf/modules.defaults.d/ModuleR.yaml" with
          """
          document: modulemd-defaults
          version: 1
          data:
            module: ModuleR
            stream: stream1
            profiles:
              stream1: [default]
          """
       When I successfully run "dnf -y module install ModuleR"
       Then a module ModuleR config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream1 |
       When I run "dnf -y module enable ModuleR:stream2"
       Then a module ModuleR config file should contain
          | Key     | Value   |
          | state   | enabled |
          | stream  | stream2 |
       When I run "dnf module list ModuleR"
       Then the command stdout should match regexp "ModuleR *stream1 \[d\] *default \[d\]"
        And the command stdout should match regexp "ModuleR *stream2 \[e\] *default"
        And the command stdout should not match regexp "ModuleR *stream2 \[e\] *default \[i\]"
