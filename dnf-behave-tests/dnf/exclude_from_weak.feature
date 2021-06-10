Feature: Skip exclude_from_weak for weak deps and autodetected exclude_from_weak for unmet weak dependencies of installed packages


Scenario: Install step also installs weak deps
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install abcde"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install-weak  | flac-0:1.3.2-8.fc29.x86_64                |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64               |
  Given I use repository "dnf-ci-fedora-updates"
  When I execute dnf with args "upgrade abcde"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |

@bz1699672
Scenario: Install without weak dependencies, upgrades ignores unmet weak dependencies of installed packages
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install abcde --setopt=exclude_from_weak=flac --setopt=exclude_from_weak_autodetect=True"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64               |
  Given I use repository "dnf-ci-fedora-updates"
  When I execute dnf with args "upgrade abcde --setopt=exclude_from_weak_autodetect=True"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
  # Install excluded_from_weak package from exclude_from_weak_autodetect
  When I execute dnf with args "install flac --setopt=exclude_from_weak_autodetect=True"
   Then the exit code is 0
    And Transaction is following
        | Action      | Package                                 |
        | install     | flac-0:1.3.3-3.fc29.x86_64              |

@bz1699672
Scenario: Install exclude_from_weak package
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install abcde --setopt=exclude_from_weak=flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | abcde-0:2.9.2-1.fc29.noarch               |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64               |
  Given I use repository "dnf-ci-fedora-updates"
  When I execute dnf with args "upgrade abcde"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | upgrade       | abcde-0:2.9.3-1.fc29.noarch               |
  When I execute dnf with args "install flac --setopt=exclude_from_weak=flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                  |
        | install       | flac-0:1.3.3-3.fc29.x86_64               |

@bz1699672
Scenario: Obsoletes are not disabled by exclude_from_weak
  Given I use repository "dnf-ci-obsoletes"
   When I execute dnf with args "install PackageB-1.0-1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-0:1.0-1.x86_64                     |
  When I execute dnf with args "upgrade --setopt=exclude_from_weak=PackageB-Obsoleter"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | PackageB-Obsoleter-0:1.0-1.x86_64           |
        | obsoleted     | PackageB-0:1.0-1.x86_64                   |
