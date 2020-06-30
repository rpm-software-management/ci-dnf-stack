@not.with_os=rhel__ge__7
@no_installroot
Feature: Test dnf-repoconfig-daemon


Background: Start dnf-repoconfig-daemon
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
    And I start dnf-repoconfig-daemon


Scenario: Listing configured repositories
   When I call repoconfig-daemon method "list"
   Then listed repositories are
        | repoid                | enabled       |
        | dnf-ci-fedora         | 1             |
        | dnf-ci-fedora-updates | 1             |
   When I call repoconfig-daemon method "list" with args "dnf-ci-fedora"
   Then listed repositories are
        | repoid                | enabled       |
        | dnf-ci-fedora         | 1             |
   When I call repoconfig-daemon method "list" with args "dnf-ci-fedora,unknown-repoid"
   Then listed repositories are
        | repoid                | enabled       |
        | dnf-ci-fedora         | 1             |


Scenario: Get information about a repository
   When I call repoconfig-daemon method "get" with args "dnf-ci-fedora"
   Then the repository is
        | key       | value                                             |
        | repoid    | dnf-ci-fedora                                     |
        | name      | dnf-ci-fedora test repository                     |
        | enabled   | 1                                                 |
        | gpgcheck  | 0                                                 |
        | baseurl   | file:///opt/behave/fixtures/repos/dnf-ci-fedora   |
   When I call repoconfig-daemon method "get" with args "unknown-repoid"
   Then I got an exception with message "org.rpm.dnf.v0.rpm.RepoConf.Error: Repository not found"


Scenario: I could enable and disable a repo
   When I call repoconfig-daemon method "disable" with args "dnf-ci-fedora,dnf-ci-fedora-updates"
   Then ids of changed repositories are
        | repoid                    |
        | dnf-ci-fedora             |
        | dnf-ci-fedora-updates     |
   When I call repoconfig-daemon method "list"
   Then listed repositories are
        | repoid                | enabled       |
        | dnf-ci-fedora         | 0             |
        | dnf-ci-fedora-updates | 0             |
   # attempt to disable already disabled repo
   When I call repoconfig-daemon method "disable" with args "dnf-ci-fedora,dnf-ci-fedora-updates"
   Then ids of changed repositories are
        | repoid                    |
   # enable one of disabled repositories
   When I call repoconfig-daemon method "enable" with args "dnf-ci-fedora"
   Then ids of changed repositories are
        | repoid                    |
        | dnf-ci-fedora             |
   When I call repoconfig-daemon method "list"
   Then listed repositories are
        | repoid                | enabled       |
        | dnf-ci-fedora         | 1             |
        | dnf-ci-fedora-updates | 0             |
