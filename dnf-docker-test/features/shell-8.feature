Feature: Downgrade, upgrade-minimal and distro-sync in dnf shell
 repo base: TestA-1 TestB-1
 repo ext1: errata bugfix: TestA-2
            errata security Moderate: TestB-2
 repo ext2: errata bugfix: TestA-3 TestB-3
 repo ext3: errata security Critical: TestB-4
            errata enhancement: TestA-4

  @setup
  Scenario: Setup (install TestA-1 TestB-1)
      Given repository "base" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 1         |
         | TestB        | Version  | 1         |
        And repository "ext1" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 2         |
         | TestB        | Version  | 2         |
        And updateinfo defined in repository "ext1"
         | Id              | Tag        | Value                  |
         | RHBA-2999-001   | Title      | TestA bugfix           |
         |                 | Type       | bugfix                 |
         |                 | Reference  | BZ111                  |
         |                 | Package    | TestA-2                |
         | RHSA-2999-002   | Title      | TestB security update  |
         |                 | Type       | security               |
         |                 | Severity   | Moderate               |
         |                 | Reference  | BZ222                  |
         |                 | Package    | TestB-2                |
        And repository "ext2" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 3         |
         | TestB        | Version  | 3         |
        And updateinfo defined in repository "ext2"
         | Id              | Tag        | Value                  |
         | RHBA-2999-003   | Title      | TestA TestB bugfix     |
         |                 | Type       | bugfix                 |
         |                 | Reference  | BZ333                  |
         |                 | Package    | TestA-3                |
         |                 | Package    | TestB-3                |
        And repository "ext3" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 4         |
         | TestB        | Version  | 4         |
        And updateinfo defined in repository "ext3"
         | Id              | Tag        | Value                  |
         | RHSA-2999-004   | Title      | TestB security update  |
         |                 | Type       | security               |
         |                 | Severity   | Critical               |
         |                 | Reference  | BZ444                  |
         |                 | Package    | TestB-4                |
         | RHEA-2999-005   | Title      | TestA enhancement      |
         |                 | Type       | enhancement            |
         |                 | Package    | TestA-4                |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestB"
        And I enable repository "ext1"
        And I enable repository "ext2"
        And I enable repository "ext3"
       Then rpmdb changes are
         | State     | Packages         |
         | installed | TestA/1, TestB/1 |

  Scenario: downgrade nonexistentpkg
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "downgrade nonexistentpkg"
     Then the command stdout should match regexp "No package.*available"
      And the command stdout should match regexp "Nothing to do"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: downgrade TestA (when it cannot be downgraded)
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "downgrade TestA"
     Then the command stdout should match regexp "Package.*lowest version.*cannot downgrade"
      And the command stdout should match regexp "Nothing to do"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: downgrade TestA (when it can be downgraded)
     When I run "dnf -y upgrade TestA-2"
     Then the command should pass
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "downgrade TestA"
      And I run dnf shell command "run"
     Then the command stdout should match regexp "Downgraded"
      And the command stdout should match regexp "TestA.*1-1"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: downgrade Test\*
     When I run "dnf -y upgrade TestA-2 TestB-2"
     Then the command should pass
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "downgrade Test\*"
      And I run dnf shell command "run"
     Then the command stdout should match regexp "Downgraded"
      And the command stdout should match regexp "TestA.*1-1"
      And the command stdout should match regexp "TestB.*1-1"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: upgrade-minimal nonexistentpkg 
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "upgrade-minimal nonexistentpkg"
     Then the command stdout should match regexp "No match for argument"
      And the command stdout should match regexp "No packages marked for upgrade"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: upgrade-minimal --bugfix Test\*
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "upgrade-minimal --bugfix Test\*"
     When I run dnf shell command "run"
     Then the command stdout should match regexp "Upgraded"
      And the command stdout should match regexp "TestA.*3-1"
      And the command stdout should match regexp "TestB.*3-1"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: upgrade-minimal --security TestA (when there is no security upgrade)
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "upgrade-minimal --security TestA"
     Then the command stdout should match regexp "No security updates needed"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: upgrade-minimal --security TestB (when there is a security upgrade)
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "upgrade-minimal --security TestB"
     When I run dnf shell command "run"
     Then the command stdout should match regexp "Upgraded"
      And the command stdout should match regexp "TestB.*4-1"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: distribution-synchronization nonexistentpkg 
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "distribution-synchronization nonexistentpkg"
     Then the command stdout should match regexp "No package.*installed"
      And the command stdout should match regexp "No packages marked for distribution synchronization"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: distro-sync TestA (when there is an upgrade)
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "distro-sync TestA"
     When I run dnf shell command "run"
     Then the command stdout should match regexp "Upgraded"
      And the command stdout should match regexp "TestA.*4-1"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: distro-sync TestB (when there is no upgrade)
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "distro-sync TestB"
     When I run dnf shell command "run"
     Then the command stdout should match regexp "Nothing to do"
     When I run dnf shell command "exit"
     Then the command should pass

  Scenario: distro-sync TestA TestB (when TestA has an upgrade and TestB no)
     When I run "dnf -y downgrade TestA-1"
     Then the command should pass
    Given I have dnf shell session opened with parameters "-y"
     When I run dnf shell command "distro-sync TestA TestB"
      And I run dnf shell command "run"
     Then the command stdout should match regexp "Upgraded"
      And the command stdout should match regexp "TestA.*4-1"
      And the command stdout should not match regexp "TestB"
     When I run dnf shell command "exit"
     Then the command should pass
