Feature: Obsoleted packages

# dnf-ci-obsoletes repo contains:
# PackageA in versions 1.0 and 3.0
# PackageA-Obsoleter, which provides PackageA in version 2.0 and obsoletes PackageA < 2.0
# PackageA-Provider which provides PackageA in versin 4.0

Background: Use dnf-ci-obsoletes repository
  Given I use repository "dnf-ci-obsoletes"


# PackageA has a split in its upgrade-path both PackageA-Obsoleter-1.0-1 and PackageA-3.0-1 are valid.
# PackageA-3.0-1 is picked because it lexicographically precedes PackageA-Obsoleter-1.0-1.
@bz1902279
Scenario: Install of obsoleted package, but higher version than obsoleted present
   When I execute dnf with args "install PackageA"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-0:3.0-1.x86_64                   |


# PackageE has a split in its upgrade-path both PackageA-Obsoleter-1.0-1 and PackageE-3.0-1 are valid.
# PackageA-Obsoleter-1.0-1 is picked because it lexicographically precedes PackageE-3.0-1.
@bz1902279
Scenario: Install of obsoleting package, even though higher version than obsoleted present
   When I execute dnf with args "install PackageE"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-Obsoleter-0:1.0-1.x86_64         |


Scenario: Upgrade of obsoleted package by package of higher version than obsoleted
   When I execute dnf with args "install PackageA-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-0:1.0-1.x86_64                   |
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | PackageA-0:3.0-1.x86_64                   |


Scenario: Install of obsoleted package
   When I execute dnf with args "install PackageB"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |


Scenario: Upgrade of obsoleted package
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-0:1.0-1.x86_64                   |
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | obsoleted     | PackageB-0:1.0-1.x86_64                   |


Scenario: Upgrade of obsoleted package if package specified by version with glob (no obsoletes applied)
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-0:1.0-1.x86_64                   |
   When I execute dnf with args "upgrade PackageB-2*"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | PackageB-0:2.0-1.x86_64                   |


@xfail @bz1672618
Scenario: Keep reason of obsoleted package
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
   When I execute dnf with args "mark remove PackageB"
   Then the exit code is 0
    And package reasons are
        | Package        | Reason     |
        | PackageB-1.0-1 | dependency |
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | remove        | PackageB-0:1.0-1.x86_64                   |
    And package reasons are
        | Package                  | Reason     |
        | PackageB-Obsoleter-1.0-1 | dependency |


Scenario: Autoremoval of obsoleted package
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | obsoleted     | PackageB-0:1.0-1.x86_64                   |
   When I execute dnf with args "autoremove"
   Then the exit code is 0
    But Transaction is empty


@xfail
@bz1672947
Scenario: Multilib obsoletes during distro-sync
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install lz4-0:1.7.5-2.fc26.i686 lz4-0:1.7.5-2.fc26.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                       |
        | install       | lz4-0:1.7.5-2.fc26.i686       |
        | install       | lz4-0:1.7.5-2.fc26.x86_64     |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "distro-sync"
   Then the exit code is 0
   Then stderr does not contain "TransactionItem not found for key: lz4"
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | lz4-0:1.8.2-2.fc29.x86_64             |
        | install       | lz4-libs-0:1.8.2-2.fc29.i686          |
        | install       | lz4-libs-0:1.8.2-2.fc29.x86_64        |
        | remove        | lz4-0:1.7.5-2.fc26.i686               |


# PackageD-0:2.0-1.x86_64 obsoletes PackageC < 2
# PackageD-0:1.0-1.x86_64 does not obsolete anything
@bz1761137
Scenario: Obsoleted package is not installed when group contains both obsoleter and obsoleted packages
   When I execute dnf with args "group install obsoleter-obsoleted"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install-group | PackageD-0:2.0-1.x86_64               |
        | group-install | Obsoleter and obsoleted               |
    And stderr is
    """
    """


@bz1761137
Scenario: Both packages are installed when group contains both obsoleter and obsoleted packages and obsoletes are switched off
   When I execute dnf with args "group install obsoleter-obsoleted --setopt=obsoletes=False"
   Then the exit code is 1
    And stderr is
    """
    Error: 
     Problem: package PackageD-2.0-1.x86_64 obsoletes PackageC < 2.0 provided by PackageC-1.0-1.x86_64
      - cannot install the best candidate for the job
      - conflicting requests
    """
