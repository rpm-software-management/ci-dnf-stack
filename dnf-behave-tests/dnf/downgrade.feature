Feature: Downgrade command


Background:
  Given I use repository "dnf-ci-fedora-updates"


# @dnf5
# TODO(nsella) different stdout
Scenario: Downgrade one RPM
   When I execute dnf with args "install flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | flac-0:1.3.3-3.fc29.x86_64                |
   When I execute dnf with args "downgrade flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | downgrade     | flac-0:1.3.3-2.fc29.x86_64                |
   When I execute dnf with args "downgrade flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | downgrade     | flac-0:1.3.3-1.fc29.x86_64                |
   When I execute dnf with args "downgrade flac"
   Then the exit code is 0
    And stderr contains "Package flac of lowest version already installed, cannot downgrade it."

@dnf5
Scenario: Downgrade RPM that requires downgrade of dependency
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | glibc-0:2.28-26.fc29.x86_64               |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch              |
        | install-dep   | glibc-common-0:2.28-26.fc29.x86_64        |
        | install-dep   | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
        | install-dep   | filesystem-0:3.9-2.fc29.x86_64            |
        | install-dep   | basesystem-0:11-6.fc29.noarch             |
   When I execute dnf with args "downgrade glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | downgrade     | glibc-0:2.28-9.fc29.x86_64                |
        | downgrade     | glibc-common-0:2.28-9.fc29.x86_64         |
        | downgrade     | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
    And package state is
        | package                                | reason     | from_repo     |
        | basesystem-11-6.fc29.noarch            | Dependency | dnf-ci-fedora |
        | filesystem-3.9-2.fc29.x86_64           | Dependency | dnf-ci-fedora |
        | glibc-2.28-9.fc29.x86_64               | User       | dnf-ci-fedora |
        | glibc-all-langpacks-2.28-9.fc29.x86_64 | Dependency | dnf-ci-fedora |
        | glibc-common-2.28-9.fc29.x86_64        | Dependency | dnf-ci-fedora |
        | setup-2.12.1-1.fc29.noarch             | Dependency | dnf-ci-fedora |
    And dnf5 transaction items for transaction "last" are
        | action    | package                                   | reason       | repository    |
        | Downgrade | glibc-0:2.28-9.fc29.x86_64                | User         | dnf-ci-fedora |
        | Downgrade | glibc-common-0:2.28-9.fc29.x86_64         | Dependency   | dnf-ci-fedora |
        | Downgrade | glibc-all-langpacks-0:2.28-9.fc29.x86_64  | Dependency   | dnf-ci-fedora |
        | Replaced  | glibc-0:2.28-26.fc29.x86_64               | User         | @System       |
        | Replaced  | glibc-all-langpacks-0:2.28-26.fc29.x86_64 | Dependency   | @System       |
        | Replaced  | glibc-common-0:2.28-26.fc29.x86_64        | Dependency   | @System       |


@dnf5
Scenario: Downgrade a package that was installed via rpm
  Given I use repository "dnf-ci-fedora"
   When I execute rpm with args "-i --nodeps {context.scenario.repos_location}/dnf-ci-fedora-updates/x86_64/flac-1.3.3-3.fc29.x86_64.rpm"
   Then the exit code is 0
   When I execute dnf with args "downgrade flac"
   Then the exit code is 0
    And Transaction is following
        | Action    | Package                    |
        | downgrade | flac-0:1.3.3-2.fc29.x86_64 |
   Then package reasons are
        | Package                  | Reason  |
        | flac-1.3.3-2.fc29.x86_64 | unknown |
    And package state is
        | package                  | reason        | from_repo             |
        | flac-1.3.3-2.fc29.x86_64 | External User | dnf-ci-fedora-updates |
    And dnf5 transaction items for transaction "last" are
        | action    | package                    | reason        | repository            |
        | Downgrade | flac-0:1.3.3-2.fc29.x86_64 | External User | dnf-ci-fedora-updates |
        | Replaced  | flac-0:1.3.3-3.fc29.x86_64 | External User | @System               |


# @dnf5
# TODO(nsella) different exit code 0
# TODO(nsella) different stderr
Scenario Outline: Check <command> exit code - package does not exist
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "<command> non-existent-package"
   Then the exit code is 1
    And stderr is
    """
    Error: No packages marked for <command>.
    """

Examples:
    | command   |
    | upgrade   |
    | downgrade |


# @dnf5
# TODO(nsella) different exit code 0
# TODO(nsella) different stdout
# TODO(nsella) different stderr
Scenario: Check downgrade exit code - package not installed
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "downgrade flac"
   Then the exit code is 1
    And stdout is
    """
    <REPOSYNC>
    Packages for argument flac available, but not installed.
    """
    And stderr is
    """
    Error: No packages marked for downgrade.
    """


# @dnf5
# TODO(nsella) different exit code 0
# TODO(nsella) different stdout
# TODO(nsella) different stderr
Scenario: Check upgrade exit code - package not installed
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "upgrade flac"
   Then the exit code is 1
    And stdout is
    """
    <REPOSYNC>
    No match for argument: flac
    """
    And stderr is
    """
    Package flac available, but not installed.
    Error: No packages marked for upgrade.
    """


# @dnf5
# TODO(nsella) different stdout
@bz1759847
Scenario: Check upgrade exit code - package already on the highest version
  Given I use repository "dnf-ci-fedora"
    And I successfully execute dnf with args "install flac-0:1.3.3-3.fc29.x86_64"
   When I execute dnf with args "upgrade flac"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Dependencies resolved.
    Nothing to do.
    Complete!
    """


# @dnf5
# TODO(nsella) different stdout
@bz1759847
Scenario: Check downgrade exit code - package already on the lowest version
  Given I use repository "dnf-ci-fedora"
    And I successfully execute dnf with args "install flac-0:1.3.2-8.fc29.x86_64"
   When I execute dnf with args "downgrade flac"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Dependencies resolved.
    Nothing to do.
    Complete!
    """
    And stderr is
    """
    Package flac of lowest version already installed, cannot downgrade it.
    """
