@xfail
Feature: Test for updateinfo
 repo base: TestA-1 TestB-1
 repo ext1: errata security Moderate: TestB-2
 repo ext2: errata bugfix: TestA-2
            errata bugfix: TestA-3 TestB-3
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
         | TestB        | Version  | 2         |
        And updateinfo defined in repository "ext1"
         | Id              | Tag        | Value                  |
         | RHSA-2999:001   | Title      | TestB security update  |
         |                 | Type       | security               |
         |                 | Description| Security Advisory      |
         |                 | Severity   | Moderate               |
         |                 | Reference  | CVE-2999-0001          |
         |                 | Reference  | BZ222                  |
         |                 | Package    | TestB-2                |
        And repository "ext2" with packages
         | Package      | Tag      | Value     |
         | TestA        | Version  | 2         |
         | TestA v3     | Version  | 3         |
         | TestB        | Version  | 3         |
        And updateinfo defined in repository "ext2"
         | Id              | Tag        | Value                  |
         | RHBA-2999:002-02| Title      | TestA bugfix           |
         |                 | Type       | bugfix                 |
         |                 | Description| Bugfix Advisory        |
         |                 | Reference  | BZ111                  |
         |                 | Package    | TestA-2                |
         | FEDORA-2999:0003| Title      | TestA TestB bugfix     |
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
         | RHSA-2999:004   | Title      | TestB security update  |
         |                 | Type       | security               |
         |                 | Severity   | Critical               |
         |                 | Reference  | CVE-2999-0002          |
         |                 | Reference  | BZ444                  |
         |                 | Package    | TestB-4                |
         | RHEA-2999:005   | Title      | TestA enhancement      |
         |                 | Type       | enhancement            |
         |                 | Package    | TestA-4                |

       When I save rpmdb
        And I enable repository "base"
        And I successfully run "dnf -y install TestA TestB"
       Then rpmdb changes are
         | State     | Packages         |
         | installed | TestA/1, TestB/1 |

  Scenario: updateinfo summary (when there's nothing to report)
       When I successfully run "dnf updateinfo summary"
       Then the command stdout should not match regexp "Updates Information Summary"

  Scenario: updateinfo --summary (when there's nothing to report)
       When I successfully run "dnf updateinfo --summary"
       Then the command stdout should not match regexp "Updates Information Summary"

  Scenario: updateinfo summary available (when there is an available update)
       When I enable repository "ext1"
        And I successfully run "dnf updateinfo summary available"
       Then the command stdout should match regexp "Updates Information Summary: available"
        And the command stdout should match regexp "1 Moderate Security notice"
         
  Scenario: updateinfo info
       When I successfully run "dnf updateinfo info"
       Then the command stdout should match regexp "TestB security update"
        And the command stdout should match regexp "Update ID.*RHSA-2999:001"
        And the command stdout should match regexp "Type.*security"
        And the command stdout should match regexp "Updated"
        And the command stdout should match regexp "Bugs.*BZ222"
        And the command stdout should match regexp "CVEs.*CVE-2999-0001"
        And the command stdout should match regexp "Description.*Security Advisory"
        And the command stdout should match regexp "Severity.*Moderate"
         
  Scenario: updateinfo --info
       When I successfully run "dnf updateinfo --info"
       Then the command stdout should match regexp "TestB security update"
        And the command stdout should match regexp "Update ID.*RHSA-2999:001"
        And the command stdout should match regexp "Type.*security"
        And the command stdout should match regexp "Updated"
        And the command stdout should match regexp "Bugs.*BZ222"
        And the command stdout should match regexp "CVEs.*CVE-2999-0001"
        And the command stdout should match regexp "Description.*Security Advisory"
        And the command stdout should match regexp "Severity.*Moderate"
         
  Scenario: updateinfo info bugfix (when there's nothing to report)
       When I successfully run "dnf updateinfo info bugfix"
       Then the command stdout should not match regexp "Update ID"

  Scenario: updateinfo list
       When I successfully run "dnf updateinfo list"
       Then the command stdout should match regexp "RHSA-2999:001.*Moderate/Sec..*TestB-2-1"

  Scenario: updateinfo --list
       When I successfully run "dnf updateinfo --list"
       Then the command stdout should match regexp "RHSA-2999:001.*Moderate/Sec..*TestB-2-1"

## severity (yum compatibility subcmd) is currently not implemented
## uncomment the following scenario when/if it is implemented in dnf
#  Scenario: updateinfo list severity Moderate
#       When I successfully run "dnf updateinfo list severity Moderate"
#       Then the command stdout should match regexp "RHSA-2999:001.*Moderate/Sec..*TestB-2-1"

  Scenario: updateinfo list all security
       When I successfully run "dnf updateinfo list all security"
       Then the command stdout should match regexp "RHSA-2999:001.*Moderate/Sec..*TestB-2-1"

  Scenario: updateinfo list updates
       When I successfully run "dnf -y update TestB"
        And I enable repository "ext2"
        And I successfully run "dnf updateinfo list updates"
       Then the command stdout should match regexp "FEDORA-2999:0003.*bugfix.*TestA-3-1.noarch"
        And the command stdout should match regexp "FEDORA-2999:0003.*bugfix.*TestB-3-1.noarch"
        And the command stdout should match regexp "RHBA-2999:002-02.*bugfix.*TestA-2-1.noarch"
         
  Scenario: updateinfo list installed
       When I successfully run "dnf updateinfo list installed"
       Then the command stdout should match regexp "RHSA-2999:001.*Moderate/Sec..*TestB-2-1"
        And the command stdout should not match regexp "FEDORA-2999:0003"
        And the command stdout should not match regexp "RHBA-2999:002-02"

  Scenario: updateinfo list available enhancement
       When I enable repository "ext3"
        And I successfully run "dnf updateinfo list available enhancement"
       Then the command stdout should match regexp "RHEA-2999:005.*enhancement.*TestA-4-1.noarch"
        And the command stdout should not match regexp "FED"
        And the command stdout should not match regexp "RH[BS]"

  Scenario: updateinfo list all bugfix
       When I successfully run "dnf updateinfo list all bugfix"
       Then the command stdout should match regexp "FEDORA-2999:0003.*bugfix.*TestA-3-1.noarch"
        And the command stdout should match regexp "FEDORA-2999:0003.*bugfix.*TestB-3-1.noarch"
        And the command stdout should match regexp "RHBA-2999:002-02.*bugfix.*TestA-2-1.noarch"
        And the command stdout should not match regexp "RH[ES]"

  Scenario: updateinfo list updates plus further opts (bz, cve, advisory)
       When I successfully run "dnf --bz 333 --cve CVE-2999-0001 --cve CVE-2999-0002 --advisory RHBA-2999:002-02 --advisory RHEA-2999:005 updateinfo list updates"
       Then the command stdout should match regexp "FEDORA-2999:0003.*bugfix.*TestA-3-1.noarch"
        And the command stdout should match regexp "FEDORA-2999:0003.*bugfix.*TestB-3-1.noarch"
        And the command stdout should match regexp "RHBA-2999:002-02.*bugfix.*TestA-2-1.noarch"
        And the command stdout should match regexp "RHSA-2999:004.*Critical/Sec.*TestB-4-1.noarch"
        And the command stdout should match regexp "RHEA-2999:005.*enhancement.*TestA-4-1.noarch"
        And the command stdout should not match regexp "RHSA-2999:001"
         
  Scenario: updateinfo info <advisory>
       When I successfully run "dnf updateinfo info FEDORA-2999:0003"
       Then the command stdout should match regexp "Update ID.*FEDORA-2999:0003"
        And the command stdout should match regexp "Type.*bugfix"
        And the command stdout should not match regexp "Update ID.*RH"

  Scenario: updateinfo info <advisory-with-respin-suffix>
       When I successfully run "dnf updateinfo info RHBA-2999:002-02"
       Then the command stdout should match regexp "Update ID.*RHBA-2999:002-02"
        And the command stdout should match regexp "Type.*bugfix"
        And the command stdout should not match regexp "Update ID.*FED"
        And the command stdout should not match regexp "Update ID.*RH[SE]"
