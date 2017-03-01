@xfail
Feature: Test for upgrade and upgrade-minimal with cve, cves, bugfix, advisory, advisories, sec-severity, secseverity and security options
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
         |                 | Reference  | CVE-2999-0001          |
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
         |                 | Reference  | CVE-2999-0002          |
         |                 | Reference  | BZ444                  |
         |                 | Package    | TestB-4                |
         | RHEA-2999-005   | Title      | TestA enhancement      |
         |                 | Type       | enhancement            |
         |                 | Package    | TestA-4                |

       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestB"
       Then rpmdb changes are
         | State     | Packages         |
         | installed | TestA/1, TestB/1 |

  Scenario: upgrade-minimal cve and advisory
       When I enable repository "ext1"
        And I enable repository "ext2"
        And I enable repository "ext3"
        And I save rpmdb
        And I run "dnf -y --cve CVE-2999-0001 --advisory RHBA-2999-001 upgrade-minimal"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA/2,TestB/2    |

  Scenario: Cleanup after upgrade-minimal cve and advisory
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestA/1,TestB/1    |

  Scenario: upgrade advisories
       When I save rpmdb
        And I run "dnf -y --advisories=RHSA-2999-004 --advisories=RHBA-2999-001 upgrade"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA/4,TestB/4    |

  Scenario: Cleanup after upgrade advisories
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestA/1,TestB/1    |

  Scenario: upgrade cves
       When I save rpmdb
        And I run "dnf -y --cves=CVE-2999-0001 --cves=CVE-2999-0002 upgrade"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestB/4            |

  Scenario: Cleanup after upgrade cves
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestB/1            |

  Scenario: upgrade-minimal sec-severity
       When I save rpmdb
        And I run "dnf -y --sec-severity Moderate upgrade-minimal"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestB/2            |

  Scenario: Cleanup after upgrade-minimal sec-severity
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestB/1            |

  Scenario: upgrade secseverity
       When I save rpmdb
        And I run "dnf -y --secseverity Critical upgrade"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestB/4            |

  Scenario: Cleanup after upgrade secseverity
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestB/1            |

  Scenario: upgrade-minimal bugfix
       When I save rpmdb
        And I run "dnf -y --bugfix upgrade-minimal"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA/3,TestB/3    |

  Scenario: Cleanup after upgrade-minimal bugfix
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestA/1,TestB/1    |

  Scenario: upgrade bugfix
       When I save rpmdb
        And I run "dnf -y --bugfix upgrade"
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA/4,TestB/4    |

  Scenario: Cleanup after upgrade bugfix
       When I save rpmdb
        And I successfully run "dnf -y history undo last"
       Then rpmdb changes are
         | State      | Packages           |
         | downgraded | TestA/1,TestB/1    |

  Scenario: upgrade-minimal security plus bugfix
       When I save rpmdb
        And I run "dnf -y --security --bugfix upgrade-minimal" 
       Then rpmdb changes are
         | State      | Packages           |
         | updated    | TestA/3,TestB/4    |
