Feature: Repolist


Background: Using repositories dnf-ci-fedora and dnf-ci-thirdparty-updates
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-thirdparty-updates"
    And I use repository "dnf-ci-fedora-updates" with configuration
        | key     | value |
        | enabled | 0     |
    And I use repository "dnf-ci-thirdparty" with configuration
        | key     | value |
        | enabled | 0     |


Scenario: Repolist without arguments
   When I execute microdnf with args "repolist"
   Then the exit code is 0
    And stdout is
      """
      repo id                   repo name
      dnf-ci-fedora             dnf-ci-fedora test repository
      dnf-ci-thirdparty-updates dnf-ci-thirdparty-updates test repository
      """


Scenario: Repolist with "--enabled"
   When I execute microdnf with args "repolist --enabled"
   Then the exit code is 0
    And stdout is
      """
      repo id                   repo name
      dnf-ci-fedora             dnf-ci-fedora test repository
      dnf-ci-thirdparty-updates dnf-ci-thirdparty-updates test repository
      """


Scenario: Repolist with "--disabled"
   When I execute microdnf with args "repolist --disabled"
   Then the exit code is 0
    And stdout is
      """
      repo id               repo name
      dnf-ci-fedora-updates dnf-ci-fedora-updates test repository
      dnf-ci-thirdparty     dnf-ci-thirdparty test repository
      """


Scenario: Repolist with "--all"
   When I execute microdnf with args "repolist --all"
   Then the exit code is 0
    And stdout is
      """
      repo id                   repo name                                   status
      dnf-ci-fedora             dnf-ci-fedora test repository              enabled
      dnf-ci-fedora-updates     dnf-ci-fedora-updates test repository     disabled
      dnf-ci-thirdparty         dnf-ci-thirdparty test repository         disabled
      dnf-ci-thirdparty-updates dnf-ci-thirdparty-updates test repository  enabled
      """


Scenario: Repolist with "--enabled --disabled"
   When I execute microdnf with args "repolist --enabled --disabled"
   Then the exit code is 0
    And stdout is
      """
      repo id                   repo name                                   status
      dnf-ci-fedora             dnf-ci-fedora test repository              enabled
      dnf-ci-fedora-updates     dnf-ci-fedora-updates test repository     disabled
      dnf-ci-thirdparty         dnf-ci-thirdparty test repository         disabled
      dnf-ci-thirdparty-updates dnf-ci-thirdparty-updates test repository  enabled
      """


# Tests for "--disablerepo" and "--enablerepo" including wildcards support
@bz1781420
Scenario: Disable all repos and then enable "dnf-ci-fedora-updates" repo
   When I execute microdnf with args "repolist --disablerepo=* --enablerepo=dnf-ci-fedora-updates --all"
   Then the exit code is 0
    And stdout is
      """
      repo id                   repo name                                   status
      dnf-ci-fedora             dnf-ci-fedora test repository             disabled
      dnf-ci-fedora-updates     dnf-ci-fedora-updates test repository      enabled
      dnf-ci-thirdparty         dnf-ci-thirdparty test repository         disabled
      dnf-ci-thirdparty-updates dnf-ci-thirdparty-updates test repository disabled
      """


Scenario: Disable "dnf-ci-thirdparty*" repos and enable "dnf-ci-fedora*" repos
   When I execute microdnf with args "repolist --disablerepo=dnf-ci-thirdparty* --enablerepo=dnf-ci-fedora* --all"
   Then the exit code is 0
    And stdout is
      """
      repo id                   repo name                                   status
      dnf-ci-fedora             dnf-ci-fedora test repository              enabled
      dnf-ci-fedora-updates     dnf-ci-fedora-updates test repository      enabled
      dnf-ci-thirdparty         dnf-ci-thirdparty test repository         disabled
      dnf-ci-thirdparty-updates dnf-ci-thirdparty-updates test repository disabled
      """


Scenario: Only "*-updates" repos are enabled
   When I execute microdnf with args "repolist --disablerepo=* --enablerepo=*-updates --all"
   Then the exit code is 0
    And stdout is
      """
      repo id                   repo name                                   status
      dnf-ci-fedora             dnf-ci-fedora test repository             disabled
      dnf-ci-fedora-updates     dnf-ci-fedora-updates test repository      enabled
      dnf-ci-thirdparty         dnf-ci-thirdparty test repository         disabled
      dnf-ci-thirdparty-updates dnf-ci-thirdparty-updates test repository  enabled
      """


Scenario: Test '?' wildcard. Only "dnf-ci-fedora-updates" repo is enabled
   When I execute microdnf with args "repolist --disablerepo=* --enablerepo=dnf-ci-??????-* --all"
   Then the exit code is 0
    And stdout is
      """
      repo id                   repo name                                   status
      dnf-ci-fedora             dnf-ci-fedora test repository             disabled
      dnf-ci-fedora-updates     dnf-ci-fedora-updates test repository      enabled
      dnf-ci-thirdparty         dnf-ci-thirdparty test repository         disabled
      dnf-ci-thirdparty-updates dnf-ci-thirdparty-updates test repository disabled
      """
