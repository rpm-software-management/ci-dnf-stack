Feature: Versionlock command can maintain versionlock.list file


Background: Set up versionlock infrastructure in the installroot
  Given I enable plugin "versionlock"
  # plugins do not honor installroot when searching their configuration
  # all the next steps are merely to set up versionlock plugin inside installroot
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
    """


Scenario: Basic commands add/exclude/list/delete/clear for manipulation with versionlock.list file are working
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install wget"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | wget-0:1.19.5-5.fc29.x86_64           |
   # add is the default command
   When I execute dnf with args "versionlock wget"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Adding versionlock on: wget-0:1.19.5-5.fc29.*
    """
   When I execute dnf with args "versionlock list"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    wget-0:1.19.5-5.fc29.*
    """
   # exclude command
   When I execute dnf with args "versionlock exclude lame"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Adding exclude on: lame-0:3.100-4.fc29.*
    """
   When I execute dnf with args "versionlock list"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    wget-0:1.19.5-5.fc29.*
    !lame-0:3.100-4.fc29.*
    """
   # delete command
   When I execute dnf with args "versionlock delete wget"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Deleting versionlock for: wget-0:1.19.5-5.fc29.*
    """
   When I execute dnf with args "versionlock list"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    !lame-0:3.100-4.fc29.*
    """
   # delete command on excluded package
   When I execute dnf with args "versionlock delete lame"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Deleting versionlock for: !lame-0:3.100-4.fc29.*
    """
   When I execute dnf with args "versionlock list"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    """
   # add command
   When I execute dnf with args "versionlock add wget"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Adding versionlock on: wget-0:1.19.5-5.fc29.*
    """
   When I execute dnf with args "versionlock list"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    wget-0:1.19.5-5.fc29.*
    """
   # clear command
   When I execute dnf with args "versionlock clear"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    """
   When I execute dnf with args "versionlock list"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    """


Scenario: Versionlock accepts --raw switch
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install flac"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | install       | flac-0:1.3.2-8.fc29.x86_64            |
   When I execute dnf with args "versionlock add --raw flac-1.3.*"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Adding versionlock on: flac-1.3.*
    """


@bz1785563
Scenario: versionlock will print just necessary information with -q option
  Given I use repository "dnf-ci-fedora"
  Given I execute dnf with args "versionlock add wget"
  When I execute dnf with args "-q versionlock"
  Then the exit code is 0
  And stdout is
    """
    wget-0:1.19.5-5.fc29.*
    """


@bz1782052
Scenario: Prevent duplicate entries in versionlock.list
  Given I use repository "dnf-ci-fedora"
    And I successfully execute dnf with args "install wget"
    And I successfully execute dnf with args "versionlock add wget"
   When I execute dnf with args "versionlock add wget"
   Then the exit code is 0
    And stdout is
    """
    <REPOSYNC>
    Package already locked in equivalent form: wget-0:1.19.5-5.fc29.*
    """


@bz1782052
Scenario: Prevent conflicting entries in versionlock.list
  Given I use repository "dnf-ci-fedora"
    And I successfully execute dnf with args "install wget"
    And I successfully execute dnf with args "versionlock add wget"
   When I execute dnf with args "versionlock exclude wget"
   Then the exit code is 1
    And stderr is
    """
    Error: Package wget-0:1.19.5-5.fc29.* is already locked
    """
