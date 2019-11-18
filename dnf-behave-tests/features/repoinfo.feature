Feature: Repoinfo


Background: Using repositories dnf-ci-fedora and dnf-ci-thirdparty-updates
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-thirdparty-updates"
    And I use repository "dnf-ci-fedora-updates" with configuration
        | key     | value |
        | enabled | 0     |
    And I use repository "dnf-ci-thirdparty" with configuration
        | key     | value |
        | enabled | 0     |

@bz1793950
Scenario: Repolist without arguments
   When I execute dnf with args "repoinfo"
   Then the exit code is 0
    And stdout matches line by line
"""

Repo-id            : dnf-ci-fedora
Repo-name          : dnf-ci-fedora test repository
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 289
Repo-available-pkgs: 289
Repo-size          : 2.0 M
Repo-baseurl       : .*/fixtures/repos/dnf-ci-fedora
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-fedora.repo

Repo-id            : dnf-ci-thirdparty-updates
Repo-name          : dnf-ci-thirdparty-updates test repository
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 6
Repo-available-pkgs: 6
Repo-size          : 36 k
Repo-baseurl       : .*/fixtures/repos/dnf-ci-thirdparty-updates
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-thirdparty-updates.repo
Total packages: 295
"""

@bz1793950
Scenario: Repoinfo without arguments and option --all
   When I execute dnf with args "repoinfo --all"
   Then the exit code is 0
    And stdout matches line by line
"""

Repo-id            : dnf-ci-fedora
Repo-name          : dnf-ci-fedora test repository
Repo-status        : enabled
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 289
Repo-available-pkgs: 289
Repo-size          : 2.0 M
Repo-baseurl       : .*/fixtures/repos/dnf-ci-fedora
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-fedora.repo

Repo-id            : dnf-ci-fedora-updates
Repo-name          : dnf-ci-fedora-updates test repository
Repo-status        : disabled
Repo-baseurl       : .*/fixtures/repos/dnf-ci-fedora-updates
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-fedora-updates.repo

Repo-id            : dnf-ci-thirdparty
Repo-name          : dnf-ci-thirdparty test repository
Repo-status        : disabled
Repo-baseurl       : .*/fixtures/repos/dnf-ci-thirdparty
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-thirdparty.repo

Repo-id            : dnf-ci-thirdparty-updates
Repo-name          : dnf-ci-thirdparty-updates test repository
Repo-status        : enabled
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 6
Repo-available-pkgs: 6
Repo-size          : 36 k
Repo-baseurl       : .*/fixtures/repos/dnf-ci-thirdparty-updates
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-thirdparty-updates.repo
Total packages: 295
"""

@bz1793950
Scenario: Repoinfo without arguments but with excludes
   When I execute dnf with args "repoinfo -x=*"
   Then the exit code is 0
    And stdout matches line by line
"""

Repo-id            : dnf-ci-fedora
Repo-name          : dnf-ci-fedora test repository
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 289
Repo-available-pkgs: 0
Repo-size          : 2.0 M
Repo-baseurl       : .*/fixtures/repos/dnf-ci-fedora
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-fedora.repo

Repo-id            : dnf-ci-thirdparty-updates
Repo-name          : dnf-ci-thirdparty-updates test repository
Repo-revision      : 1550000000
Repo-updated       : .*
Repo-pkgs          : 6
Repo-available-pkgs: 0
Repo-size          : 36 k
Repo-baseurl       : .*/fixtures/repos/dnf-ci-thirdparty-updates
Repo-expire        : .*
Repo-filename      : .*/etc/yum.repos.d/dnf-ci-thirdparty-updates.repo
Total packages: 295
"""
