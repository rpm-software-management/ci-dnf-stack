@no_installroot
@destructive
Feature: Repolist when all repositories are disabled


Background:
  Given I use repository "dnf-ci-fedora" with configuration
        |key      | value |
        | enabled | 0     |


@not.with_os=rhel__eq__8
Scenario: Repolist without arguments
   When I execute microdnf with args "repolist"
   Then the exit code is 0
    And stdout is empty


@not.with_os=rhel__eq__8
Scenario: Repolist with "--enabled"
   When I execute microdnf with args "repolist --enabled"
   Then the exit code is 0
    And stdout is empty


@not.with_os=rhel__eq__8
Scenario: Repolist with "--disabled"
   When I execute microdnf with args "repolist --disabled"
   Then the exit code is 0
    And stdout is
      """
      repo id       repo name
      dnf-ci-fedora dnf-ci-fedora test repository
      """


@not.with_os=rhel__eq__8
Scenario: Repolist with "--all"
   When I execute microdnf with args "repolist --all"
   Then the exit code is 0
    And stdout is
      """
      repo id       repo name                       status
      dnf-ci-fedora dnf-ci-fedora test repository disabled
      """


@not.with_os=rhel__eq__8
Scenario: Repolist with "--enabled --disabled"
   When I execute microdnf with args "repolist --enabled --disabled"
   Then the exit code is 0
    And stdout is
      """
      repo id       repo name                       status
      dnf-ci-fedora dnf-ci-fedora test repository disabled
      """
