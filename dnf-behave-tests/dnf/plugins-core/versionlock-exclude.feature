Feature: Tests excluding capabilities of the versionlock plugin


Background: Set up versionlock infrastructure in the installroot
  Given I enable plugin "versionlock"
  # plugins do not honor installroot when searching their configuration
  # following steps are merely to set up versionlock plugin inside installroot
  And I configure dnf with
    | key            | value                                     |
    | pluginconfpath | {context.dnf.installroot}/etc/dnf/plugins |
  And I create and substitute file "/etc/dnf/plugins/versionlock.conf" with
    """
    [main]
    enabled = 1
    locklist = {context.dnf.installroot}/etc/dnf/plugins/versionlock.list
    """
  And I create file "/etc/dnf/plugins/versionlock.list" with
    """
    !wget-0:1.19.6-5.fc29.*
    """
  # check that both excluded and newer versions of the package are available
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


Scenario: The excluded newest version of the package is not installed
   When I execute dnf with args "install wget"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | wget-0:1.19.5-5.fc29.x86_64           |


Scenario: The excluded version of the package is not installed as a dependency
   When I execute dnf with args "install abcde"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | abcde-0:2.9.3-1.fc29.noarch           |
        | install-dep   | wget-0:1.19.5-5.fc29.x86_64           |
        | install-weak  | flac-0:1.3.3-3.fc29.x86_64            |


Scenario: The excluded newest version of the package is installed when passed as a local file
   When I execute dnf with args "install {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/wget-1.19.6-5.fc29.x86_64.rpm"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | wget-0:1.19.6-5.fc29.x86_64           |


