Feature: Test for check-update, upgrade, update, upgrade-minimal and update-minimal with security option
 repo base: TestA-1 TestB-1
 repo sec-err-1: errata security Low: TestA-2
 repo sec-err-2: errata security Moderate: TestA-3
 repo enh-err: errata enhancement: TestA-4 TestB-2

  @setup
  Scenario: Setup (install TestA-1 TestB-1)
      Given repository "base" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 1         |
         | TestB        | Version  | 1         |
        And repository "sec-err-1" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 2         |
        And updateinfo defined in repository "sec-err-1"
         | Id              | Tag        | Value                  |
         | RHSA-2999-001   | Title      | TestA security update  |
         |                 | Type       | security               |
         |                 | Severity   | Low                    |
         |                 | Package    | TestA-2                |
        And repository "sec-err-2" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 3         |
        And updateinfo defined in repository "sec-err-2"
         | Id              | Tag        | Value                  |
         | RHSA-2999-002   | Title      | TestA security update  |
         |                 | Type       | security               |
         |                 | Severity   | Moderate               |
         |                 | Package    | TestA-3                |
        And repository "enh-err" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 4         |
         | TestB        | Version  | 2         |
        And updateinfo defined in repository "enh-err"
         | Id              | Tag        | Value                  |
         | RHEA-2999-003   | Title      | TestA TestB enh        |
         |                 | Type       | enhancement            |
         |                 | Package    | TestA-4                |
         |                 | Package    | TestB-2                |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestB"
       Then rpmdb changes are
         | State     | Packages         |
         | installed | TestA/1, TestB/1 |

  Scenario: Security check-update when there are no such updates
       When I run "dnf --security check-update"
       Then the command exit code is 0
        And the command stdout should not match regexp "TestA"
        And the command stdout should not match regexp "TestB"

  Scenario: Security check-update when there are such updates
       When I enable repository "sec-err-1"
        And I enable repository "sec-err-2"
        And I enable repository "enh-err"
        And I run "dnf --security check-update"
       Then the command exit code is 100
        And the command stdout should match regexp "TestA.*2-1.*sec-err-1"
        And the command stdout should match regexp "TestA.*3-1.*sec-err-2"
        And the command stdout should match regexp "TestA.*4-1.*enh-err"
        And the command stdout should not match regexp "TestB"

  Scenario: Security update
       When I save rpmdb
        And I successfully run "dnf -y --security update"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA/4            |

  Scenario: Cleanup after security update
       When I save rpmdb
        And I successfully run "dnf -y history undo last" 
       Then rpmdb changes are
         | State      | Packages             |
         | downgraded | TestA/1              |

  Scenario: Security upgrade
       When I save rpmdb
        And I successfully run "dnf -y --security upgrade"
       Then rpmdb changes are
         | State      | Packages             |
         | updated    | TestA/4              |

  Scenario: Cleanup after security upgrade
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages             |
         | downgraded | TestA/1              |

  Scenario: Security update-minimal
       When I save rpmdb
        And I successfully run "dnf -y --security update-minimal"
       Then rpmdb changes are
         | State      | Packages             |
         | updated    | TestA/3              |

  Scenario: Cleanup after security update-minimal
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestA/1            |

  Scenario: Security upgrade-minimal
       When I save rpmdb
        And I successfully run "dnf -y --security upgrade-minimal"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA/3            |
