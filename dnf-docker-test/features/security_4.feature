Feature: Test for upgrade and upgrade-minimal with bz and security options
 repo base: TestA-1 TestB-1
 repo sec-err-1: errata security Low: TestA-2
 repo sec-err-2: errata security Moderate: TestB-2
 repo bug-err: errata bugfix: TestA-3 TestB-3

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
         |                 | Reference  | BZ123                  |
         |                 | Package    | TestA-2                |
        And repository "sec-err-2" with packages
         | Package      | Tag      | Value     |
         | TestB        | Version  | 2         |
        And updateinfo defined in repository "sec-err-2"
         | Id              | Tag        | Value                  |
         | RHSA-2999-002   | Title      | TestB security update  |
         |                 | Type       | security               |
         |                 | Severity   | Moderate               |
         |                 | Reference  | BZ234                  |
         |                 | Reference  | BZ345                  |
         |                 | Package    | TestB-2                |
        And repository "bug-err" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 3         |
         | TestB        | Version  | 3         |
        And updateinfo defined in repository "bug-err"
         | Id              | Tag        | Value                  |
         | RHBA-2999-003   | Title      | TestA TestB bugfix     |
         |                 | Type       | bugfix                 |
         |                 | Reference  | BZ456                  |
         |                 | Package    | TestA-3                |
         |                 | Package    | TestB-3                |
       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestB"
       # verze maji byt TestA-1 a TestB-1
       Then rpmdb changes are
         | State     | Packages     |
         | installed | TestA, TestB |

  Scenario: Security plus three explicitly mentioned bzs upgrade
       When I enable repository "sec-err-1"
        And I enable repository "sec-err-2"
        And I enable repository "bug-err"
        And I save rpmdb
        And I run "dnf -y --bz 123 --bz 234 --bz 345 --security upgrade" 
       # verze maji byt TestA-3 a TestB-3
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA,TestB        |

  Scenario: Cleanup after security plus bzs upgrade
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       # verze maji byt TestA-1 a TestB-1
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestA,TestB        |

  Scenario: Security plus three explicitly mentioned bzs upgrade-minimal
       When I save rpmdb
        And I run "dnf -y --bz 123 --bz 234 --bz 345 --security upgrade-minimal" 
       # verze maji byt TestA-2 a TestB-2
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA,TestB        |
