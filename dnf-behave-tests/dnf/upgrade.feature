Feature: Upgrade single RPMs


Background: Install RPMs
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-thirdparty"
   When I execute dnf with args "install glibc flac wget SuperRipper"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | flac-0:1.3.2-8.fc29.x86_64                |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
        | install       | SuperRipper-0:1.0-1.x86_64                |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | basesystem-0:11-6.fc29.noarch             |
        | install-dep   | glibc-common-0:2.28-9.fc29.x86_64         |
        | install-dep   | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | install-dep   | abcde-0:2.9.2-1.fc29.noarch               |
        | install-weak  | FlacBetterEncoder-0:1.0-1.x86_64          |


@dnf5daemon
@dnf5
@tier1
@bz1649286
Scenario: Upgrade one RPM
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade glibc"
   Then the exit code is 0
    And stdout does not contain "Upgrade *: +glibc"
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |


@dnf5daemon
@dnf5
Scenario: Upgrade two RPMs
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade glibc flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgrade       | flac-0:1.3.3-3.fc29.x86_64                |


@dnf5
Scenario: Upgrade list of packages, none of them has an upgrade available
   When I execute dnf with args "upgrade flac abcde"
   Then the exit code is 0
    And stdout contains "Nothing to do."
    And Transaction is empty


@dnf5
Scenario: Upgrade list of packages, one of them is not available
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade flac nosuchpkg"
   Then the exit code is 1
    And stderr is
    """
    Failed to resolve the transaction:
    No match for argument: nosuchpkg
    """
    And Transaction is empty


@dnf5
Scenario: Upgrade list of packages with --skip-unavailable, one of them is not available
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade --skip-unavailable nosuchpkg flac"
   Then the exit code is 0
    And stderr is
    """
    No match for argument: nosuchpkg

    Warning: skipped PGP checks for 1 package(s).
    """
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | flac-0:1.3.3-3.fc29.x86_64                |


@dnf5
Scenario: Upgrade list of packages, one of them is not installed
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade flac dwm"
   Then the exit code is 1
    And stderr is
    """
    Failed to resolve the transaction:
    Packages for argument 'dwm' available, but not installed.
    """
    And Transaction is empty


@dnf5
Scenario: Upgrade list of packages with --skip-unavailable, one of them is not installed
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade --skip-unavailable dwm flac"
   Then the exit code is 0
    And stderr is
    """
    Packages for argument 'dwm' available, but not installed.

    Warning: skipped PGP checks for 1 package(s).
    """
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | flac-0:1.3.3-3.fc29.x86_64                |


# @dnf5
# TODO(nsella) rpmdb check fail
@tier1
@bz1670776 @bz1671683
Scenario: Upgrade all RPMs from multiple repositories with best=False
  Given I use repository "dnf-ci-fedora-updates"
  Given I use repository "dnf-ci-fedora-updates-testing"
    And I use repository "dnf-ci-thirdparty-updates"
  Given I configure dnf with
        | key  | value |
        | best | False |
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And stderr is
    """
    Problem: cannot install the best update candidate for package SuperRipper-1.0-1.x86_64
      - nothing provides unsatisfiable needed by SuperRipper-1.3-1.x86_64
    """
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgrade       | flac-0:1.4.0-1.fc29.x86_64                |
        | upgrade       | wget-1:1.19.5-5.fc29.x86_64               |
        | upgrade       | SuperRipper-0:1.2-1.x86_64                |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
        | broken        | SuperRipper-0:1.3-1.x86_64                |


# @dnf5
# TODO(nsella) stderr differs, --nobest argument not supported
@tier1
@bz1670776 @bz1671683
Scenario: Upgrade all RPMs from multiple repositories with best=True
  Given I use repository "dnf-ci-fedora-updates"
  Given I use repository "dnf-ci-fedora-updates-testing"
    And I use repository "dnf-ci-thirdparty-updates"
   When I execute dnf with args "upgrade"
   Then the exit code is 1
    And stderr is
    """
    Error: 
     Problem: cannot install the best update candidate for package SuperRipper-1.0-1.x86_64
      - nothing provides unsatisfiable needed by SuperRipper-1.3-1.x86_64
    """
   When I execute dnf with args "upgrade --nobest"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgrade       | flac-0:1.4.0-1.fc29.x86_64                |
        | upgrade       | wget-1:1.19.5-5.fc29.x86_64               |
        | upgrade       | SuperRipper-0:1.2-1.x86_64                |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
        | broken        | SuperRipper-0:1.3-1.x86_64                |


# @dnf5
# TODO(nsella) rpmdb check fail, update command alias not supported
@bz1659390
Scenario: Print information about skipped packages
  Given I use repository "dnf-ci-thirdparty-updates"
   When I execute dnf with args "update --setopt 'best=0'"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | SuperRipper-0:1.2-1.x86_64                |
        | broken        | SuperRipper-0:1.3-1.x86_64                |
   Then stdout section "Upgrading:" contains "SuperRipper\s+x86_64\s+1.2-1\s+dnf-ci-thirdparty-updates"
   Then stdout section "Skipping packages with broken dependencies:" contains "SuperRipper\s+x86_64\s+1.3-1\s+dnf-ci-thirdparty-updates"
   Then stdout section "Upgraded:" contains "SuperRipper-1.2-1.x86_64"
   Then stdout section "Skipped:" contains "SuperRipper-1.3-1.x86_64"


# @dnf5
# TODO(nsella) update command alias not supported, stderr differs
@bz1585138
Scenario Outline: Print correct number of available updates if update <type> is given
  Given I execute dnf with args "install CQRlib-extension"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | CQRlib-extension-0:1.5-2.x86_64           |
   Then I use repository "dnf-ci-thirdparty-updates"
   When I execute dnf with args "update <type>" 
   Then the exit code is 0
    And Transaction is empty
    And stderr contains "No security updates needed, but 2 updates available"

Examples:
        | type          |
        | --security    |
        | --bugfix      |
        | --enhancement |


# @dnf5
# TODO(nsella) update command alias not supported, stderr differs
@bz1585138
Scenario Outline: Print correct number of available updates if update <type> is given and updateinfo is available
  Given I use repository "dnf-ci-fedora-updates"
    And I use repository "dnf-ci-thirdparty-updates"
   When I execute dnf with args "update <type>" 
   Then the exit code is 0
    And Transaction is empty
    And stderr contains "No security updates needed, but 7 updates available"

Examples:
        | type          |
        | --security    |
        | --enhancement |
