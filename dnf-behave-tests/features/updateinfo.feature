Feature: Listing available updates using the dnf updateinfo command


Background:
  Given I use repository "dnf-ci-fedora"


Scenario: Listing available updates
   When I execute dnf with args "install glibc flac"
   Then Transaction is following
        | Action        | Package                                  |
        | install       | glibc-0:2.28-9.fc29.x86_64               |
        | install       | flac-0:1.3.2-8.fc29.x86_64               |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch             |
        | install-dep   | basesystem-0:11-6.fc29.noarch            |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64           |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64 |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64        |
    And the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "updateinfo list"
    And the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    FEDORA-2999:002-02     enhancement flac-1.3.3-8.fc29.x86_64
    FEDORA-2018-318f184000 bugfix      glibc-2.28-26.fc29.x86_64
    """


Scenario Outline: updateinfo <summary alias> (when there's nothing to report)
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
   When I execute dnf with args "updateinfo summary"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    """

Examples: 
        | summary alias |
        | summary       |
        | --summary     |
 

Scenario Outline: updateinfo <summary alias> available (when there is an available update)
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo <summary alias> available"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Updates Information Summary: available
        1 Bugfix notice(s)
        1 Enhancement notice(s)
    """

Examples: 
        | summary alias |
        | summary       |
        | --summary     |


Scenario Outline: updateinfo info
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo <info alias> available"
   Then the exit code is 0
    And stdout matches line by line
    """
    <REPOSYNC>
    ===============================================================================
      flac enhacements
    ===============================================================================
      Update ID: FEDORA-2999:002-02
           Type: enhancement
        Updated: 2019-01-1\d \d\d:00:00
    Description: Enhance some stuff
       Severity: Moderate

    ===============================================================================
      glibc bug fix
    ===============================================================================
      Update ID: FEDORA-2018-318f184000
           Type: bugfix
        Updated: 2019-01-1\d \d\d:00:00
           Bugs: 222 - 222
           CVEs: 2999
               : CVE-2999
    Description: Fix some stuff
       Severity: none
    """

Examples: 
        | info alias |
        | info       |
        | --info     |
         

Scenario: updateinfo info security (when there's nothing to report)
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo info security"
   Then the exit code is 0
   And stdout is
   """
   <REPOSYNC>
   """


Scenario Outline: updateinfo <list alias>
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo <list alias>"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    FEDORA-2999:002-02     enhancement flac-1.3.3-8.fc29.x86_64
    FEDORA-2018-318f184000 bugfix      glibc-2.28-26.fc29.x86_64
    """

Examples:
        | list alias |
        | list       |
        | --list     |


Scenario: updateinfo list all security
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "install glibc flac CQRlib"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo list all security"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    i FEDORA-2018-318f184113 Moderate/Sec. CQRlib-1.1.2-16.fc29.x86_64
    """
                 

Scenario: updateinfo list updates
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "update glibc flac"
    And the exit code is 0
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "updateinfo list updates"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    FEDORA-2999:002-02     enhancement flac-1.3.3-8.fc29.x86_64
    FEDORA-2018-318f184112 enhancement flac-1.4.0-1.fc29.x86_64
    """


Scenario: updateinfo list installed
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "update glibc flac"
    And the exit code is 0
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "updateinfo list installed"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    FEDORA-2018-318f184000 bugfix glibc-2.28-26.fc29.x86_64
    """


Scenario: updateinfo list available enhancement
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "updateinfo list available enhancement"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    FEDORA-2999:002-02     enhancement flac-1.3.3-8.fc29.x86_64
    FEDORA-2018-318f184112 enhancement flac-1.4.0-1.fc29.x86_64
    """


Scenario: updateinfo list all bugfix
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo list all bugfix"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
      FEDORA-2018-318f184000 bugfix glibc-2.28-26.fc29.x86_64
    """


Scenario Outline: updateinfo list updates plus <option>
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "<option> <value> updateinfo list updates"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    FEDORA-2018-318f184000 bugfix glibc-2.28-26.fc29.x86_64
    """

Examples:
        | option      | value                  |
        | --bz        | 222                    |
        | --cve       | 2999                   |
        | --cve       | CVE-2999               |
        | --advisory  | FEDORA-2018-318f184000 |


Scenario: updateinfo info <advisory>
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo info FEDORA-2018-318f184000"
   Then the exit code is 0
    And stdout matches line by line
    """
    <REPOSYNC>
    ===============================================================================
      glibc bug fix
    ===============================================================================
      Update ID: FEDORA-2018-318f184000
           Type: bugfix
        Updated: 2019-01-1\d \d\d:00:00
           Bugs: 222 - 222
           CVEs: 2999
               : CVE-2999
    Description: Fix some stuff
       Severity: none
    """
        

Scenario: updateinfo info <advisory-with-respin-suffix>
   When I execute dnf with args "install glibc flac"
   Then the exit code is 0
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo info FEDORA-2999:002-02"
   Then the exit code is 0
    And stdout matches line by line
    """
    <REPOSYNC>
    ===============================================================================
      flac enhacements
    ===============================================================================
      Update ID: FEDORA-2999:002-02
           Type: enhancement
        Updated: 2019-01-1\d \d\d:00:00
    Description: Enhance some stuff
       Severity: Moderate
    """
   Then stdout contains "Update\s+ID:\s+FEDORA-2999:002-02"
    And stdout contains "Type:\s+enhancement"
    And stdout does not contain "glibc"


@bz1750528
Scenario Outline: updateinfo lists advisories referencing CVE
  Given I successfully execute dnf with args "install glibc flac"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo <options>"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    2999     bugfix glibc-2.28-26.fc29.x86_64
    CVE-2999 bugfix glibc-2.28-26.fc29.x86_64
    """

Examples:
    | options             |
    | --list --with-cve   |
    # yum compatibility
    | list cves           |
    | list --with-cve     |
    | --list cves         |


Scenario Outline: updateinfo lists advisories referencing bugzilla
  Given I successfully execute dnf with args "install glibc flac"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo <options>"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    222 bugfix glibc-2.28-26.fc29.x86_64
    """

Examples:
    | options             |
    | --list --with-bz    |
    # yum compatibility
    | list bugzillas      |
    | list bzs            |


@bz1728004
Scenario: updateinfo show <advisory> of the running kernel after a kernel update
   When I execute dnf with args "install kernel"
   Then Transaction is following
        | Action        | Package                                  |
        | install       | kernel-0:4.18.16-300.fc29.x86_64         |
        | install-dep   | kernel-core-0:4.18.16-300.fc29.x86_64    |
        | install-dep   | kernel-modules-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
    And I execute dnf with args "updateinfo list kernel"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    FEDORA-2019-348e185000 bugfix kernel-4.19.15-300.fc29.x86_64
    """
   When I execute dnf with args "update kernel"
   Then Transaction is following
        | Action        | Package                                  |
        | install       | kernel-0:4.19.15-300.fc29.x86_64         |
        | install-dep   | kernel-core-0:4.19.15-300.fc29.x86_64    |
        | install-dep   | kernel-modules-0:4.19.15-300.fc29.x86_64 |
   When I execute dnf with args "updateinfo list kernel"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    """


Scenario Outline: updateinfo lists advisories using direct commands (yum compat)
  Given I successfully execute dnf with args "install glibc flac"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "<command>"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    FEDORA-2999:002-02     enhancement flac-1.3.3-8.fc29.x86_64
    FEDORA-2018-318f184000 bugfix      glibc-2.28-26.fc29.x86_64
    """

Examples:
    | command         |
    | list-sec        |
    | list-security   |
    | list-updateinfo |


Scenario Outline: updateinfo shows info for advisories using direct commands (yum compat)
  Given I successfully execute dnf with args "install glibc flac"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "<command>"
   Then the exit code is 0
    And stdout matches line by line
    """
    <REPOSYNC>
    ===============================================================================
      flac enhacements
    ===============================================================================
      Update ID: FEDORA-2999:002-02
           Type: enhancement
        Updated: 2019-01-1\d \d\d:00:00
    Description: Enhance some stuff
       Severity: Moderate

    ===============================================================================
      glibc bug fix
    ===============================================================================
      Update ID: FEDORA-2018-318f184000
           Type: bugfix
        Updated: 2019-01-1\d \d\d:00:00
           Bugs: 222 - 222
           CVEs: 2999
               : CVE-2999
    Description: Fix some stuff
       Severity: none
    """

Examples:
    | command         |
    | info-sec        |
    | info-security   |
    | info-updateinfo |


Scenario: updateinfo shows summary for advisories using direct commands (yum compat)
  Given I successfully execute dnf with args "install glibc flac"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "summary-updateinfo"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Updates Information Summary: available
        1 Bugfix notice(s)
        1 Enhancement notice(s)
    """


@bz1801092
Scenario: updateinfo lists advisories referencing CVE with dates in verbose mode (DNF version)
  Given I set dnf command to "dnf"
    And I successfully execute dnf with args "install glibc flac"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo -v --list --with-cve"
   Then the exit code is 0
    And stdout matches line by line
    """
    DNF version: .*
    cachedir: .*
    User-Agent: constructed: .*
    repo: using cache for: dnf-ci-fedora
    dnf-ci-fedora: using metadata from .*
    repo: downloading from remote: dnf-ci-fedora-updates
    dnf-ci-fedora-updates test repository .* MB/s | .*
    dnf-ci-fedora-updates: using metadata from .*
    <REPOSYNC>
    2999     bugfix glibc-2.28-26.fc29.x86_64 2019-01-1\d \d\d:00:00
    CVE-2999 bugfix glibc-2.28-26.fc29.x86_64 2019-01-1\d \d\d:00:00
    """


@bz1801092
Scenario: updateinfo lists advisories referencing CVE with dates in verbose mode (YUM version)
  Given I set dnf command to "yum"
    And I successfully execute dnf with args "install glibc flac"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "updateinfo -v --list --with-cve"
   Then the exit code is 0
    And stdout matches line by line
    """
    YUM version: .*
    cachedir: .*
    User-Agent: constructed: .*
    repo: using cache for: dnf-ci-fedora
    dnf-ci-fedora: using metadata from .*
    repo: downloading from remote: dnf-ci-fedora-updates
    dnf-ci-fedora-updates test repository .* MB/s | .*
    dnf-ci-fedora-updates: using metadata from .*
    <REPOSYNC>
    2999     bugfix glibc-2.28-26.fc29.x86_64 2019-01-1\d \d\d:00:00
    CVE-2999 bugfix glibc-2.28-26.fc29.x86_64 2019-01-1\d \d\d:00:00
    """
