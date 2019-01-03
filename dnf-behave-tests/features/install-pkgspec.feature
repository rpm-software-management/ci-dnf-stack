Feature: Install RPMs by pkgspec


@tier1
Scenario: Install an RPM by name
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Install an RPM by name-version
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem-3.9"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Install an RPM by name-version-release
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem-3.9-2.fc29"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Install an RPM by name-version-release.arch
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem-3.9-2.fc29.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |


Scenario: Install an RPM by name-epoch:version-release.arch
  Given I use the repository "dnf-ci-fedora"
   When I execute dnf with args "install filesystem-0:3.9-2.fc29.x86_64"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | filesystem-0:3.9-2.fc29.x86_64        |
        | install       | setup-0:2.12.1-1.fc29.noarch          |
