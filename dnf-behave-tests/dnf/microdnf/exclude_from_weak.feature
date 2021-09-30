Feature: Skip exclude_from_weak for weak deps and autodetected exclude_from_weak for unmet weak dependencies of installed packages

Background: Prepare /user dir
  Given I use repository "dnf-ci-fedora"
    # "/usr" directory is needed to load rpm database (to overcome bad heuristics in libdnf created by Colin Walters)
    And I create directory "/usr"

Scenario: Install step also installs weak deps
  Given I use repository "dnf-ci-fedora"
   When I execute microdnf with args "install abcde"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install-weak  | flac-0:1.3.2-8.fc29.x86_64                |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64               |
  Given I use repository "dnf-ci-fedora-updates"
  When I execute microdnf with args "upgrade abcde"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
        | upgraded      | abcde-0:2.9.2-1.fc29.noarch               |

@bz2005305
@bz1699672
Scenario: Install without weak dependencies, upgrades ignores unmet weak dependencies of installed packages
  Given I use repository "dnf-ci-fedora"
   When I configure dnf with
      | key    | value |
      | exclude_from_weak            | flac |
      | exclude_from_weak_autodetect | True |
    And I execute microdnf with args "install abcde"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install       | wget-0:1.19.5-5.fc29.x86_64               |
  Given I use repository "dnf-ci-fedora-updates"
   When I configure dnf with
      | key    | value |
      | exclude_from_weak            |      |
      | exclude_from_weak_autodetect | True |
    And I execute microdnf with args "upgrade abcde"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
        | upgraded      | abcde-0:2.9.2-1.fc29.noarch               |
  # Install excluded_from_weak package from exclude_from_weak_autodetect
  When I execute microdnf with args "install flac"
   Then the exit code is 0
    And microdnf transaction is
        | Action      | Package                                 |
        | install     | flac-0:1.3.3-3.fc29.x86_64              |

@bz2005305
@bz1699672
Scenario: Install exclude_from_weak package
  Given I use repository "dnf-ci-fedora"
   When I configure dnf with
      | key    | value |
      | exclude_from_weak            | flac |
      | exclude_from_weak_autodetect | True |
    And I execute microdnf with args "install abcde"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64               |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute microdnf with args "upgrade abcde"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
        | upgraded      | abcde-0:2.9.2-1.fc29.noarch               |
    And I execute microdnf with args "install flac"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | flac-0:1.3.3-3.fc29.x86_64                |

@bz2005305
@bz1699672
Scenario: Obsoletes are not disabled by exclude_from_weak
  Given I use repository "dnf-ci-obsoletes"
   When I execute microdnf with args "install PackageB-1.0-1"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | PackageB-0:1.0-1.x86_64                   |
   When I configure dnf with
      | key    | value |
      | exclude_from_weak            | PackageB-Obsoleter  |
      | exclude_from_weak_autodetect | True                |
  When I execute microdnf with args "upgrade"
   Then the exit code is 0
    And microdnf transaction is
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64         |
        | obsoleted     | PackageB-0:1.0-1.x86_64                   |
