Feature: Upgrade single RPMs


Background: Install RPMs
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-thirdparty"
    # "/usr" directory is needed to load rpm database (to overcome bad heuristics in libdnf created by Colin Walters)
    And I create directory "/usr"
   When I execute microdnf with args "install glibc flac wget SuperRipper"
   Then the exit code is 0
    And microdnf transaction is
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

@bz1905471
@tier1
Scenario: Upgrade one RPM
  Given I use repository "dnf-ci-fedora-updates"
   When I execute microdnf with args "upgrade glibc"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgraded      | glibc-0:2.28-9.fc29.x86_64                |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgraded      | glibc-common-0:2.28-9.fc29.x86_64         |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgraded      | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |

@bz1905471
Scenario: Upgrade one RPM using "update" command alias
  Given I use repository "dnf-ci-fedora-updates"
   When I execute microdnf with args "update glibc"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgraded      | glibc-0:2.28-9.fc29.x86_64                |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgraded      | glibc-common-0:2.28-9.fc29.x86_64         |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgraded      | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |

@bz1905471
Scenario: Upgrade two RPMs
  Given I use repository "dnf-ci-fedora-updates"
   When I execute microdnf with args "upgrade glibc flac"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgraded      | glibc-0:2.28-9.fc29.x86_64                |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgraded      | glibc-common-0:2.28-9.fc29.x86_64         |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgraded      | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | upgrade       | flac-0:1.3.3-3.fc29.x86_64                |
        | upgraded      | flac-0:1.3.2-8.fc29.x86_64                |

@bz1905471
@tier1
@bz1670776 @bz1671683
Scenario: Upgrade all RPMs from multiple repositories with best=False
  Given I use repository "dnf-ci-fedora-updates"
  Given I use repository "dnf-ci-fedora-updates-testing"
    And I use repository "dnf-ci-thirdparty-updates"
  Given I configure dnf with
        | key  | value |
        | best | False |
   When I execute microdnf with args "upgrade"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgraded      | glibc-0:2.28-9.fc29.x86_64                |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgraded      | glibc-common-0:2.28-9.fc29.x86_64         |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgraded      | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | upgrade       | flac-0:1.4.0-1.fc29.x86_64                |
        | upgraded      | flac-0:1.3.2-8.fc29.x86_64                |
        | upgrade       | wget-1:1.19.5-5.fc29.x86_64               |
        | upgraded      | wget-0:1.19.5-5.fc29.x86_64               |
        | upgrade       | SuperRipper-0:1.2-1.x86_64                |
        | upgraded      | SuperRipper-0:1.0-1.x86_64                |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
        | upgraded      | abcde-0:2.9.2-1.fc29.noarch               |

@bz1905471
@tier1
@bz1670776 @bz1671683
Scenario: Upgrade all RPMs from multiple repositories with best=True
  Given I use repository "dnf-ci-fedora-updates"
  Given I use repository "dnf-ci-fedora-updates-testing"
    And I use repository "dnf-ci-thirdparty-updates"
   When I execute microdnf with args "upgrade"
   Then the exit code is 1
    And stderr is
    """
    error: Could not depsolve transaction; 1 problem detected:
     Problem: cannot install the best update candidate for package SuperRipper-1.0-1.x86_64
      - nothing provides unsatisfiable needed by SuperRipper-1.3-1.x86_64 from dnf-ci-thirdparty-updates
    """
   When I execute microdnf with args "upgrade --nobest"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
        | upgraded      | glibc-0:2.28-9.fc29.x86_64                |
        | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
        | upgraded      | glibc-common-0:2.28-9.fc29.x86_64         |
        | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | upgraded      | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
        | upgrade       | flac-0:1.4.0-1.fc29.x86_64                |
        | upgraded      | flac-0:1.3.2-8.fc29.x86_64                |
        | upgrade       | wget-1:1.19.5-5.fc29.x86_64               |
        | upgraded      | wget-0:1.19.5-5.fc29.x86_64               |
        | upgrade       | SuperRipper-0:1.2-1.x86_64                |
        | upgraded      | SuperRipper-0:1.0-1.x86_64                |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
        | upgraded      | abcde-0:2.9.2-1.fc29.noarch               |
