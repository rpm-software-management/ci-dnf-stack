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


@dnfdaemon
Scenario: Repolist without arguments
   When I execute dnf with args "repolist"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora"
    And stdout contains "dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates"
    And stdout does not contain "dnf-ci-fedora-updates"
    And stdout does not contain "dnf-ci-thirdparty\s+dnf-ci-thirdparty"


Scenario: Repolist with "enabled"
   When I execute dnf with args "repolist enabled"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora"
    And stdout contains "dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates"
    And stdout does not contain "dnf-ci-fedora-updates"
    And stdout does not contain "dnf-ci-thirdparty\s+dnf-ci-thirdparty"


@dnfdaemon
Scenario: Repolist with "--enabled"
   When I execute dnf with args "repolist --enabled"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora"
    And stdout contains "dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates"
    And stdout does not contain "dnf-ci-fedora-updates"
    And stdout does not contain "dnf-ci-thirdparty\s+dnf-ci-thirdparty"


Scenario: Repolist with "disabled"
   When I execute dnf with args "repolist disabled"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora-updates\s+dnf-ci-fedora-updates"
    And stdout contains "dnf-ci-thirdparty\s+dnf-ci-thirdparty"
    And stdout does not contain "dnf-ci-fedora\s+dnf-ci-fedora"
    And stdout does not contain "dnf-ci-thirdparty-updates"


Scenario: Repolist with "all"
   When I execute dnf with args "repolist all"
   Then the exit code is 0
    And stdout contains "dnf-ci-fedora\s+dnf-ci-fedora test repository\s+enabled"
    And stdout contains "dnf-ci-fedora-updates\s+dnf-ci-fedora-updates test repository\s+disabled"
    And stdout contains "dnf-ci-thirdparty\s+dnf-ci-thirdparty test repository\s+disabled"
    And stdout contains "dnf-ci-thirdparty-updates\s+dnf-ci-thirdparty-updates test repository\s+enabled"


Scenario: Repolist in verbose mode without arguments
  Given I set dnf command to "dnf"
   When I execute dnf with args "repolist --verbose"
   Then the exit code is 0
    And stdout matches line by line
"""
DNF version: .*
cachedir: .*
Repo-id            : dnf-ci-fedora
Repo-name          : dnf-ci-fedora test repository
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 289
Repo-available-pkgs: 289
Repo-size          : 2\.[0-9] M
Repo-baseurl       : .*/fixtures/repos/dnf-ci-fedora
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-fedora.repo

Repo-id            : dnf-ci-thirdparty-updates
Repo-name          : dnf-ci-thirdparty-updates test repository
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 6
Repo-available-pkgs: 6
Repo-size          : 3[0-9] k
Repo-baseurl       : .*/fixtures/repos/dnf-ci-thirdparty-updates
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-thirdparty-updates.repo
Total packages: 295
"""

@bz1812682
Scenario: Repolist with -d 6
#  -d with 6 or higher is similar to --verbose option
  Given I set dnf command to "yum"
   When I execute dnf with args "-d 6 repolist"
   Then the exit code is 0
    And stdout matches line by line
"""
YUM version: .*
cachedir: .*
Repo-id            : dnf-ci-fedora
Repo-name          : dnf-ci-fedora test repository
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 289
Repo-available-pkgs: 289
Repo-size          : 2\.[0-9] M
Repo-baseurl       : .*/fixtures/repos/dnf-ci-fedora
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-fedora.repo

Repo-id            : dnf-ci-thirdparty-updates
Repo-name          : dnf-ci-thirdparty-updates test repository
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 6
Repo-available-pkgs: 6
Repo-size          : 3[0-9] k
Repo-baseurl       : .*/fixtures/repos/dnf-ci-thirdparty-updates
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-thirdparty-updates.repo
Total packages: 295
"""

@bz2066334
Scenario: Repolist in verbose mode with manual repository having no cpeid
  Given I use repository "manual-test"
    And I copy repository "manual-test" for modification
    And I generate repodata for repository "manual-test" with extra arguments "--distro RHEL8"
    And I use repository "manual-test"
   When I execute dnf with args "repolist --verbose"
   Then the exit code is 0
    And stderr does not contain "Error: basic_string"
