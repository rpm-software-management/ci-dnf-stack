@jiraRHELPLAN-6083
Feature: platform pseudo-module based on /etc/os-release

  @setup
  Scenario: setup
    Given repository "ModularRepo" with packages
         | Package       | Tag      | Value |
         | modA/TestA    | Version  | 1     |
         |               | Release  | 1     |
      And a file "modules.yaml" with type "modules" added into repository "ModularRepo"
          """
          ---
          data:
            artifacts:
              rpms: ["TestA-0:1-1.modA.noarch"]
            components:
              rpms:
                TestA: {rationale: 'rationale for TestA'}
            description: Module ModuleA description
            license:
              module: [MIT]
            name: ModuleA
            profiles:
              default:
                rpms: [TestA]
            stream: streamA
            dependencies:
              - requires:
                  pseudoplatform: [streamA]
            summary: Module ModuleA summary
            version: 1
          document: modulemd
          version: 2
          """
      And I successfully run "cp /etc/os-release /etc/os-release.dnf-test-backup"
     When I enable repository "ModularRepo"
     Then I successfully run "dnf makecache"

  Scenario: I can't enable module requiring different platform pseudo module
       When I run "dnf -y module enable ModuleA:streamA"
       Then the command should fail
        And the command stderr should match regexp "nothing provides module\(pseudoplatform:streamA\) needed by module ModuleA:streamA"

  Scenario: Platform pseudo module name:stream is created based on /etc/os-release
      Given a file "/etc/os-release" with
          """
          NAME=PsedoDistro
          VERSION="99 (A-team)"
          ID=pseudo
          VERSION_ID=99
          PLATFORM_ID="pseudoplatform:streamA"
          PRETTY_NAME="PseudoDistro 99 (A-team)"
          """
       When I run "dnf -y module enable ModuleA:streamA"
       Then the command should pass
        And a module "ModuleA" config file should contain
           | Key      | Value   |
           | state    | enabled |
           | stream   | streamA |

  Scenario: I can't see pseudo-module in module listing
       When I run "dnf module list --enabled"
       Then the command stdout should not match regexp "pseudoplatform"
       When I run "dnf module list --installed"
       Then the command stdout should not match regexp "pseudoplatform"

  Scenario: I can't list info for the pseudo-module
       When I run "dnf module info pseudoplatform"
       Then the command should fail
        And the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Unable to resolve argument pseudoplatform
          """
        And the command stderr should match line by line regexp
          """
          ^Error: No matching Modules to list
          """

  Scenario: I can't enable pseudo-module
       When I run "dnf module -y enable pseudoplatform:streamA"
       Then the command should fail
        And the command stderr should match line by line regexp
          """
          ^Error: Problems in request:
          ^missing groups or modules: pseudoplatform
          """

  Scenario: I can't install pseudo-module
       When I run "dnf module -y install pseudoplatform:streamA"
       Then the command should fail
        And the command stderr should match line by line regexp
          """
          ^Error: Problems in request:
          ^missing groups or modules: pseudoplatform
          """

  Scenario: I can't disable pseudo-module
       When I run "dnf module -y disable pseudoplatform:streamA"
       Then the command should fail
        And the command stderr should match line by line regexp
          """
          ?Unable to resolve argument pseudoplatform:streamA
          ^Error: Problems in request:
          ^missing groups or modules: pseudoplatform
          """

  Scenario: I can't update pseudo-module
       When I run "dnf module -y update pseudoplatform:streamA"
       Then the command should fail
        And the command stderr should match line by line regexp
          """
          ^Error: No such module: pseudoplatform:streamA
          """

  Scenario: I can't remove pseudo-module
       When I run "dnf module -y remove pseudoplatform:streamA"
       Then the command should pass
        And the command stdout should match line by line regexp
          """
          ?Last metadata
          ^Dependencies resolved.
          ^Nothing to do.
          ^Complete!
          """
        And the command stderr should match line by line regexp
          """
          ^Problems in request:
          ^missing groups or modules: pseudoplatform
          """

  @cleanup
  Scenario: cleanup
    Given I successfully run "mv /etc/os-release.dnf-test-backup /etc/os-release"
