Feature: Test upgrading installonly packages


Background:
  Given I use repository "dnf-ci-fedora"


@bz1668256 @bz1616191 @bz1639429
Scenario: Install multiple versions of an installonly package with a limit of 2
  Given I set config option "installonly_limit" to "2"
   When I execute dnf with args "install kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "upgrade kernel-core"
   Then the exit code is 0
   Then stderr does not contain "cannot install both"
    And Transaction is empty
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64  |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64 |

@bz1769788
Scenario: Install multiple versions of an installonly package and keep reason
   When I execute dnf with args "install kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade --nobest"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "autoremove"
   Then the exit code is 0
    And Transaction is empty

Scenario: Remove all installonly packages but keep the latest
   When I execute dnf with args "install kernel-core"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "upgrade"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                  |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64     |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64    |
        | unchanged        | kernel-core-0:4.18.16-300.fc29.x86_64 |
   When I execute dnf with args "remove --oldinstallonly"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                  |
        | unchanged       | kernel-core-0:4.20.6-300.fc29.x86_64   |
        | remove        | kernel-core-0:4.19.15-300.fc29.x86_64    |
        | remove        | kernel-core-0:4.18.16-300.fc29.x86_64    |

@no_installroot
@destructive
Scenario: Remove all installonly packages but keep the latest and running kernel-core-0:4.18.16-300.fc29.x86_64
  Given I fake kernel release to "4.18.16-300.fc29.x86_64"
   When I execute dnf with args "install kernel-core --repofrompath=r,{context.dnf.repos[dnf-ci-fedora].path} --repo=r --nogpgcheck"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "upgrade --repofrompath=r,{context.dnf.repos[dnf-ci-fedora-updates].path} --repo=r --nogpgcheck"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | kernel-core-0:4.19.15-300.fc29.x86_64 |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64 |
  Given I use repository "dnf-ci-fedora-updates-testing"
   When I execute dnf with args "upgrade --repofrompath=r,{context.dnf.repos[dnf-ci-fedora-updates-testing].path} --repo=r --nogpgcheck"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                  |
        | install       | kernel-core-0:4.20.6-300.fc29.x86_64     |
        | unchanged     | kernel-core-0:4.19.15-300.fc29.x86_64    |
        | unchanged     | kernel-core-0:4.18.16-300.fc29.x86_64    |
        | upgrade       | wget-1:1.19.5-5.fc29.x86_64              |
   When I execute dnf with args "remove --oldinstallonly"
   Then the exit code is 0
    And Transaction is following
        | Action          | Package                                  |
        | unchanged       | kernel-core-0:4.20.6-300.fc29.x86_64     |
        | remove          | kernel-core-0:4.19.15-300.fc29.x86_64    |
        | unchanged        | kernel-core-0:4.18.16-300.fc29.x86_64   |
