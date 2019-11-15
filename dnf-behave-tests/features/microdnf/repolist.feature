@no_installroot
@destructive
Feature: Repolist


Background: Using repositories dnf-ci-fedora and dnf-ci-thirdparty-updates
  Given I delete file "/etc/dnf/dnf.conf"
    And I delete file "/etc/yum.repos.d/*.repo" with globs
    And I use repository "dnf-ci-fedora"
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
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-fedora\s+dnf-ci-fedora test repository
      dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates test repository
      """


Scenario: Repolist with "--enabled"
   When I execute microdnf with args "repolist --enabled"
   Then the exit code is 0
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-fedora\s+dnf-ci-fedora test repository
      dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates test repository
      """


Scenario: Repolist with "--disabled"
   When I execute microdnf with args "repolist --disabled"
   Then the exit code is 0
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-fedora-updates\s+dnf-ci-fedora-updates test repository
      dnf-ci-thirdparty\s+dnf-ci-thirdparty test repository
      """


Scenario: Repolist with "--all"
   When I execute microdnf with args "repolist --all"
   Then the exit code is 0
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-fedora\s+dnf-ci-fedora test repository
      dnf-ci-fedora-updates\s+dnf-ci-fedora-updates test repository\s+disabled
      dnf-ci-thirdparty\s+dnf-ci-thirdparty test repository\s+disabled
      dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates test repository
      """


Scenario: Repolist with "--enabled --disabled"
   When I execute microdnf with args "repolist --enabled --disabled"
   Then the exit code is 0
    And stdout matches line by line
      """
      repo id\s+repo name
      dnf-ci-fedora\s+dnf-ci-fedora test repository
      dnf-ci-fedora-updates\s+dnf-ci-fedora-updates test repository\s+disabled
      dnf-ci-thirdparty\s+dnf-ci-thirdparty test repository\s+disabled
      dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates test repository
      """
