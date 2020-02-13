@no_installroot
@destructive
Feature: Repolist when all repositories are disabled


Background:
  Given I delete file "/etc/dnf/dnf.conf"
    And I delete file "/etc/yum.repos.d/*.repo" with globs
    And I delete directory "/var/lib/dnf/modulefailsafe/"
    And I use repository "dnf-ci-fedora" with configuration
        |key      | value |
        | enabled | 0     |


Scenario: Repolist without arguments
   When I execute microdnf with args "repolist"
   Then the exit code is 0
    And stdout is empty


Scenario: Repolist with "--enabled"
   When I execute microdnf with args "repolist --enabled"
   Then the exit code is 0
    And stdout is empty


# two versions of the same test due to https://github.com/rpm-software-management/microdnf/pull/66
# the difference is in trailing spaces in stdout
@not.with_os=rhel__eq__8
Scenario: Repolist with "--disabled"
   When I execute microdnf with args "repolist --disabled"
   Then the exit code is 0
    And stdout is
      """
      repo id       repo name
      dnf-ci-fedora dnf-ci-fedora test repository
      """
@use.with_os=rhel__eq__8
Scenario: Repolist with "--disabled"
   When I execute microdnf with args "repolist --disabled"
   Then the exit code is 0
    And stdout is
      """
      repo id       repo name                    
      dnf-ci-fedora dnf-ci-fedora test repository
      """


Scenario: Repolist with "--all"
   When I execute microdnf with args "repolist --all"
   Then the exit code is 0
    And stdout is
      """
      repo id       repo name                       status
      dnf-ci-fedora dnf-ci-fedora test repository disabled
      """


Scenario: Repolist with "--enabled --disabled"
   When I execute microdnf with args "repolist --enabled --disabled"
   Then the exit code is 0
    And stdout is
      """
      repo id       repo name                       status
      dnf-ci-fedora dnf-ci-fedora test repository disabled
      """
