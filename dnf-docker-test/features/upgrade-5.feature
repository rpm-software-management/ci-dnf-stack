@bz1585138
Feature: Print correct number of available updates if update type is given

  @setup
  Scenario: setup
    Given repository "base" with packages
         | Package  | Tag      | Value  |
         | TestA    |          |        |
         | TestB    |          |        |
         | TestC    |          |        |
         | TestD    |          |        |
         | TestE    |          |        |
      And repository "ext1" with packages
         | Package  | Tag      | Value  |
         | TestA    | Version  | 2      |
         | TestB    | Version  | 2      |
         | TestC    | Version  | 2      |
      And repository "ext2" with packages
         | Package  | Tag      | Value  |
         | TestA    | Version  | 3      |
         | TestB    | Version  | 3      |
      And updateinfo defined in repository "ext2"
         | Id              | Tag        | Value                  |
         | RHEA-2999:005   | Title      | TestA enhancement      |
         |                 | Type       | enhancement            |
         |                 | Package    | TestA-3                |

     When I enable repository "base"
      And I successfully run "dnf -y install TestA TestB TestC"
      And I enable repository "ext1"

  Scenario: Print correct number of available updates when upgrading with --security
      When I save rpmdb
       And I successfully run "dnf -y upgrade --security"
      Then rpmdb does not change
       And the command stderr should match regexp "No security updates needed, but 3 updates available"

  Scenario: Print correct number of available updates when upgrading with --bugfix
      When I save rpmdb
       And I successfully run "dnf -y upgrade --bugfix"
      Then rpmdb does not change
       And the command stderr should match regexp "No security updates needed, but 3 updates available"

  Scenario: Print correct number of available updates when upgrading with --enhancement
      When I save rpmdb
       And I successfully run "dnf -y upgrade --enhancement"
      Then rpmdb does not change
       And the command stderr should match regexp "No security updates needed, but 3 updates available"

  @setup
  Scenario: Enable repository ext2
      When I enable repository "ext2"

  Scenario: Print correct number of available updates when upgrading with --security, even when there is updateinfo defined
      When I save rpmdb
       And I successfully run "dnf -y upgrade --security"
      Then rpmdb does not change
       And the command stderr should match regexp "No security updates needed, but 3 updates available"

  Scenario: Print correct number of available updates when upgrading with --bugfix, even when there is updateinfo defined
      When I save rpmdb
       And I successfully run "dnf -y upgrade --bugfix"
      Then rpmdb does not change
       And the command stderr should match regexp "No security updates needed, but 3 updates available"
