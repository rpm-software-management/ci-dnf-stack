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
    No match for argument: wget
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
