Feature: Tests locking capabilities of the versionlock plugin


Background: Set up versionlock infrastructure in the installroot
  Given I enable plugin "versionlock"
  # plugins do not honor installroot when searching their configuration
  # all the next steps are merely to set up versionlock plugin inside installroot
  And I create and substitute file "/etc/dnf/dnf.conf" with
    """
    [main]
    gpgcheck=1
    installonly_limit=3
    clean_requirements_on_remove=True
    pluginconfpath={context.dnf.installroot}/etc/dnf/plugins
    """
  And I create and substitute file "/etc/dnf/plugins/versionlock.conf" with
    """
    [main]
    enabled = 1
    locklist = {context.dnf.installroot}/etc/dnf/plugins/versionlock.list
    """
  And I create file "/etc/dnf/plugins/versionlock.list" with
    """
    wget-0:1.19.5-5.fc29.*
    """
  And I do not set config file
  # check that both locked and newer versions of the package are available
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf with args "repoquery wget"
   Then the exit code is 0
    And stdout is
    """
    wget-0:1.19.5-5.fc29.src
    wget-0:1.19.5-5.fc29.x86_64
    wget-0:1.19.6-5.fc29.src
    wget-0:1.19.6-5.fc29.x86_64
    """


Scenario: I can list all versions of locked package
   When I execute dnf with args "list --showduplicates wget"
   Then stdout is
   # there are intentional trailing spaces after dnf-ci-fedora
   # TODO fix output in the list command
    """
    <REPOSYNC>
    Available Packages
    wget.src                    1.19.5-5.fc29                  dnf-ci-fedora        
    wget.x86_64                 1.19.5-5.fc29                  dnf-ci-fedora        
    wget.src                    1.19.6-5.fc29                  dnf-ci-fedora-updates
    wget.x86_64                 1.19.6-5.fc29                  dnf-ci-fedora-updates
    """


Scenario: The locked version of the package gets installed although newer one is available
   When I execute dnf with args "install wget"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | wget-0:1.19.5-5.fc29.x86_64           |


Scenario: The locked version of the package gets installed as a dependency
   When I execute dnf with args "install abcde"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | wget-0:1.19.5-5.fc29.x86_64           |
        | install       | abcde-0:2.9.3-1.fc29.noarch           |
        | install       | flac-0:1.3.3-3.fc29.x86_64            |


Scenario: I can reinstall the installed locked version of the package
  Given I successfully execute dnf with args "install wget-1.19.5"
   When I execute dnf with args "reinstall wget"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | reinstall     | wget-0:1.19.5-5.fc29.x86_64           |


Scenario: I cannot upgrade the locked version of the package
  Given I successfully execute dnf with args "install wget-1.19.5"
   When I execute dnf with args "upgrade wget"
   Then the exit code is 0
    And Transaction is empty


Scenario: I can remove the installed locked version of the package
  Given I successfully execute dnf with args "install wget-1.19.5"
   When I execute dnf with args "remove wget"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | remove        | wget-0:1.19.5-5.fc29.x86_64           |


@bz1431491
Scenario: Locking does not require that the package exists in a repository
  Given I drop repository "dnf-ci-fedora"
   When I execute dnf with args "install wget"
   Then the exit code is 1
    And stdout is
    """
    <REPOSYNC>
    All matches were filtered out by exclude filtering for argument: wget
    """
    And stderr is
    """
    Error: Unable to find a match: wget
    """


@bz1643676
Scenario Outline: Version accepts pattern <pattern> in the lock file
  Given I create file "/etc/dnf/plugins/versionlock.list" with
    """
    <pattern>
    """
   When I execute dnf with args "install wget"
   Then the exit code is 0 
    And Transaction is following
        | Action        | Package                               |
        | install       | wget-0:1.19.5-5.fc29.x86_64           |

Examples:
    | pattern           |
    | wget-0:1.19.5*    |
    | wget-0:1.19.5-*   |


@bz1726712
Scenario: I can upgrade to the locked version of the package when older version is installed
  Given I successfully execute dnf with args "install wget-1.19.5"
    And I create file "/etc/dnf/plugins/versionlock.list" with
    """
    wget-0:1.19.6-5.fc29.*
    """
   When I execute dnf with args "update wget"
   Then the exit code is 0 
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64           |


Scenario: Versionlock can lock only parts of the package version
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
    And I use repository "dnf-ci-fedora-updates-testing"
    And I create file "/etc/dnf/plugins/versionlock.list" with
    """
    flac-1.3.*
    """
   When I execute dnf with args "repoquery flac"
   Then the exit code is 0
    And stdout is
    """
    flac-0:1.3.2-8.fc29.src
    flac-0:1.3.2-8.fc29.x86_64
    flac-0:1.3.3-1.fc29.src
    flac-0:1.3.3-1.fc29.x86_64
    flac-0:1.3.3-2.fc29.src
    flac-0:1.3.3-2.fc29.x86_64
    flac-0:1.3.3-3.fc29.src
    flac-0:1.3.3-3.fc29.x86_64
    flac-0:1.4.0-1.fc29.src
    flac-0:1.4.0-1.fc29.x86_64
    """
   When I execute dnf with args "install flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | flac-0:1.3.3-3.fc29.x86_64            |


@bz1750620
Scenario: Check-update command does not report updates filtered out by the versionlock
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac-0:1.3.2-8.fc29"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | flac-0:1.3.2-8.fc29.x86_64            |
  Given I use repository "dnf-ci-fedora-updates"
    And I use repository "dnf-ci-fedora-updates-testing"
  # no versionlock rule for the flac package
  Given I create file "/etc/dnf/plugins/versionlock.list" with
    """
    """
   When I execute dnf with args "check-update"
   Then the exit code is 100
    And stdout is
    """
    <REPOSYNC>

    flac.x86_64              1.4.0-1.fc29              dnf-ci-fedora-updates-testing
    """
  # flac package versionlocked on specific minor version
  Given I create file "/etc/dnf/plugins/versionlock.list" with
    """
    flac-0:1.3.*
    """
   When I execute dnf with args "check-update"
   Then the exit code is 100
    And stdout is
    """
    <REPOSYNC>

    flac.x86_64                  1.3.3-3.fc29                  dnf-ci-fedora-updates
    """
  # flac package versionlocked on specific version
  Given I create file "/etc/dnf/plugins/versionlock.list" with
    """
    flac-0:1.3.2-8.fc29.*
    """
   When I execute dnf with args "check-update"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    """
