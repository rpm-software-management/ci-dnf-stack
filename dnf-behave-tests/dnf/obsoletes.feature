Feature: Obsoleted packages

# dnf-ci-obsoletes repo contains:
# PackageA in versions 1.0 and 3.0
# PackageA-Obsoleter, which provides PackageA in version 2.0 and obsoletes PackageA < 2.0
# PackageA-Provider which provides PackageA in versin 4.0

Background: Use dnf-ci-obsoletes repository
  Given I use repository "dnf-ci-obsoletes"


@dnf5
# PackageA has a split in its upgrade-path both PackageA-Obsoleter-1.0-1 and PackageA-3.0-1 are valid.
# PackageA-3.0-1 is picked because it lexicographically precedes PackageA-Obsoleter-1.0-1.
@bz1902279
Scenario: Install of obsoleted package, but higher version than obsoleted present
   When I execute dnf with args "install PackageA"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-0:3.0-1.x86_64                   |
    And package state is
        | package               | reason | from_repo        |
        | PackageA-3.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action  | package                 | reason | repository       |
        | Install | PackageA-0:3.0-1.x86_64 | User   | dnf-ci-obsoletes |


@dnf5
# PackageE has a split in its upgrade-path both PackageA-Obsoleter-1.0-1 and PackageE-3.0-1 are valid.
# PackageA-Obsoleter-1.0-1 is picked because it lexicographically precedes PackageE-3.0-1.
@bz1902279
Scenario: Install of obsoleting package, even though higher version than obsoleted present
   When I execute dnf with args "install PackageE"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-Obsoleter-0:1.0-1.x86_64         |
    And package state is
        | package                         | reason | from_repo        |
        | PackageA-Obsoleter-1.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action  | package                           | reason | repository       |
        | Install | PackageA-Obsoleter-0:1.0-1.x86_64 | User   | dnf-ci-obsoletes |


# @dnf5
# TODO(nsella) different exit code
Scenario: Do not install of obsoleting package using upgrade command, when obsoleted package not on the system
   When I execute dnf with args "upgrade PackageA-Obsoleter"
   Then the exit code is 1
    And Transaction is empty


@dnf5
@bz1818118
Scenario: Install of obsoleting package using upgrade command, when obsoleted package on the system
  Given I execute dnf with args "install PackageE-0:1.0-1.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageE-0:1.0-1.x86_64                   |
   When I execute dnf with args "upgrade PackageA-Obsoleter"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-Obsoleter-0:1.0-1.x86_64         |
        | obsoleted     | PackageE-0:1.0-1.x86_64                   |
    And package state is
        | package                         | reason | from_repo        |
        | PackageA-Obsoleter-1.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action   | package                           | reason | repository       |
        | Install  | PackageA-Obsoleter-0:1.0-1.x86_64 | User   | dnf-ci-obsoletes |
        | Replaced | PackageE-0:1.0-1.x86_64           | User   | @System          |

@dnf5
# TODO(lukash) passes with reason = User, but correct outcome is reason = External User
Scenario: Obsoleting a package that was installed via rpm, with --best
   When I execute rpm with args "-i --nodeps {context.scenario.repos_location}/dnf-ci-obsoletes/x86_64/PackageB-1.0-1.x86_64.rpm"
   Then the exit code is 0
   When I execute dnf with args "upgrade --best"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | obsoleted     | PackageB-0:1.0-1.x86_64                   |
    And package state is
        | package                         | reason | from_repo        |
        | PackageB-Obsoleter-1.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action   | package                           | reason        | repository       |
        | Install  | PackageB-Obsoleter-0:1.0-1.x86_64 | User          | dnf-ci-obsoletes |
        | Replaced | PackageB-0:1.0-1.x86_64           | External User | @System          |

@dnf5
Scenario: Obsoleting a package that was installed via rpm, with --nobest
   When I execute rpm with args "-i --nodeps {context.scenario.repos_location}/dnf-ci-obsoletes/x86_64/PackageB-1.0-1.x86_64.rpm"
   Then the exit code is 0
   When I execute dnf with args "upgrade --nobest"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | obsoleted     | PackageB-0:1.0-1.x86_64                   |
    And package state is
        | package                         | reason        | from_repo        |
        | PackageB-Obsoleter-1.0-1.x86_64 | External User | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action   | package                           | reason        | repository       |
        | Install  | PackageB-Obsoleter-0:1.0-1.x86_64 | External User | dnf-ci-obsoletes |
        | Replaced | PackageB-0:1.0-1.x86_64           | External User | @System          |

@dnf5
@bz1818118
Scenario: Install of obsoleting package from commandline using upgrade command, when obsoleted package on the system
  Given I execute dnf with args "install PackageE-0:1.0-1.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageE-0:1.0-1.x86_64                   |
   When I execute dnf with args "upgrade {context.dnf.fixturesdir}/repos/dnf-ci-obsoletes/x86_64/PackageA-Obsoleter-1.0-1.x86_64.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageA-Obsoleter-0:1.0-1.x86_64         |
        | obsoleted     | PackageE-0:1.0-1.x86_64                   |
    And package state is
        | package                         | reason | from_repo    |
        | PackageA-Obsoleter-1.0-1.x86_64 | User   | @commandline |
    And dnf5 transaction items for transaction "last" are
        | action   | package                           | reason | repository   |
        | Install  | PackageA-Obsoleter-0:1.0-1.x86_64 | User   | @commandline |
        | Replaced | PackageE-0:1.0-1.x86_64           | User   | @System      |

@dnf5
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
    And package state is
        | package               | reason | from_repo        |
        | PackageA-3.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action   | package                 | reason | repository       |
        | Upgrade  | PackageA-0:3.0-1.x86_64 | User   | dnf-ci-obsoletes |
        | Replaced | PackageA-0:1.0-1.x86_64 | User   | @System          |


@dnf5
Scenario: Install of obsoleted package
   When I execute dnf with args "install PackageB"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
    And package state is
        | package                         | reason | from_repo        |
        | PackageB-Obsoleter-1.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action  | package                           | reason | repository       |
        | Install | PackageB-Obsoleter-0:1.0-1.x86_64 | User   | dnf-ci-obsoletes |


@dnf5
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
    And package state is
        | package                         | reason | from_repo        |
        | PackageB-Obsoleter-1.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action   | package                           | reason | repository       |
        | Install  | PackageB-Obsoleter-0:1.0-1.x86_64 | User   | dnf-ci-obsoletes |
        | Replaced | PackageB-0:1.0-1.x86_64           | User   | @System          |


@dnf5
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
    And package state is
        | package               | reason | from_repo        |
        | PackageB-2.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action   | package                 | reason | repository       |
        | Upgrade  | PackageB-0:2.0-1.x86_64 | User   | dnf-ci-obsoletes |
        | Replaced | PackageB-0:1.0-1.x86_64 | User   | @System          |


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


# TODO(jkolarik): autoremove not yet available in dnf5
# @dnf5
Scenario: Autoremoval of obsoleted package
   When I execute dnf with args "install PackageB-1.0"
   Then the exit code is 0
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | obsoleted     | PackageB-0:1.0-1.x86_64                   |
    And package state is
        | package                         | reason | from_repo        |
        | PackageB-Obsoleter-1.0-1.x86_64 | User   | dnf-ci-obsoletes |
    And dnf5 transaction items for transaction "last" are
        | action   | package                           | reason | repository       |
        | Install  | PackageB-Obsoleter-0:1.0-1.x86_64 | User   | dnf-ci-obsoletes |
        | Replaced | PackageB-0:1.0-1.x86_64           | User   | @System          |
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


@dnf5
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


@dnf5
@bz1761137
Scenario: Both packages are installed when group contains both obsoleter and obsoleted packages and obsoletes are switched off
   When I execute dnf with args "group install obsoleter-obsoleted --setopt=obsoletes=False"
   Then the exit code is 1
    And dnf4 stderr is
    """
    Error: 
     Problem: package PackageD-2.0-1.x86_64 obsoletes PackageC < 2.0 provided by PackageC-1.0-1.x86_64
      - cannot install the best candidate for the job
      - conflicting requests
    """
    And dnf5 stderr is
    """
    Failed to resolve the transaction:
    Problem: package PackageD-2.0-1.x86_64 obsoletes PackageC < 2.0 provided by PackageC-1.0-1.x86_64
      - cannot install the best candidate for the job
      - conflicting requests
    """
