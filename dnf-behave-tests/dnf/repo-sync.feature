Feature: Tests for the repository syncing functionality


Background: Force column width
# Some of the curl errors can be quite long and since they are
# truncated: https://github.com/rpm-software-management/dnf5/issues/1829
# we need to force the width to see them in full.
Given I set environment variable "FORCE_COLUMNS" to "400"


@bz1763663
@bz1679509
@bz1692452
Scenario: The default value of skip_if_unavailable is False
  Given I configure dnf with
        | key      | value      |
        | reposdir | /testrepos |
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key             | value              |
        | baseurl         | /non/existent/repo |
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr matches line by line
    """
    <REPOSYNC>
    >>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///non/existent/repo/repodata/repomd.xml \[Couldn't open file /non/existent/repo/repodata/repomd.xml\] - file:///non/existent/repo/repodata/repomd.xml
    >>> Usable URL not found
    Failed to download metadata \(baseurl: "/non/existent/repo"\) for repository "testrepo": Usable URL not found
    """


@bz1689931
Scenario: There is global skip_if_unavailable option
  Given I configure dnf with
        | key                 | value      |
        | reposdir            | /testrepos |
        | skip_if_unavailable | True       |
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key             | value              |
        | baseurl         | /non/existent/repo |
   When I execute dnf with args "makecache"
   Then the exit code is 0
    And stdout is
    """
    Metadata cache created.
    """
    And stderr matches line by line
    """
    <REPOSYNC>
    >>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///non/existent/repo/repodata/repomd.xml \[Couldn't open file /non/existent/repo/repodata/repomd.xml\] - file:///non/existent/repo/repodata/repomd.xml
    >>> Usable URL not found
    Repositories loaded.
    """


Scenario: Per repo skip_if_unavailable configuration
  Given I configure dnf with
        | key      | value      |
        | reposdir | /testrepos |
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key                 | value              |
        | baseurl             | /non/existent/repo |
        | skip_if_unavailable | True               |
   When I execute dnf with args "makecache"
   Then the exit code is 0
    And stdout is
    """
    Metadata cache created.
    """
    And stderr matches line by line
    """
    <REPOSYNC>
    >>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///non/existent/repo/repodata/repomd.xml \[Couldn't open file /non/existent/repo/repodata/repomd.xml\] - file:///non/existent/repo/repodata/repomd.xml
    >>> Usable URL not found
    Repositories loaded.
    """


@bz1689931
Scenario: The repo configuration takes precedence over the global one
  Given I configure dnf with
        | key                 | value      |
        | reposdir            | /testrepos |
        | skip_if_unavailable | True       |
    And I configure a new repository "testrepo" in "{context.dnf.installroot}/testrepos" with
        | key                 | value              |
        | baseurl             | /non/existent/repo |
        | skip_if_unavailable | False              |
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr matches line by line
    """
    <REPOSYNC>
    >>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///non/existent/repo/repodata/repomd.xml \[Couldn't open file /non/existent/repo/repodata/repomd.xml\] - file:///non/existent/repo/repodata/repomd.xml
    >>> Usable URL not found
    Failed to download metadata \(baseurl: "/non/existent/repo"\) for repository "testrepo": Usable URL not found
    """


@bz1741442
@bz1752362
Scenario: Test repo_gpgcheck=1 error if repomd.xml.asc is not present
Given I use repository "dnf-ci-fedora" with configuration
      | key           | value |
      | repo_gpgcheck | 1     |
 When I execute dnf with args "makecache"
 Then the exit code is 1
 And stderr contains ">>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///.*/dnf-ci-fedora/repodata/repomd.xml.asc"
  And stderr contains ">>> GPG verification is enabled, but GPG signature is not available. This may be an error or the repository does not support GPG verification:"


@bz1713627
# reported as https://github.com/rpm-software-management/dnf5/issues/2064
@xfail
Scenario: Missing baseurl/metalink/mirrorlist
  Given I configure a new repository "testrepo" with
        | key      | value        |
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr is
        """
        <REPOSYNC>
        Failed to download metadata (baseurl: "") for repository "testrepo"
         No valid source (baseurl, mirrorlist or metalink) found for repository "testrepo"
        """
   When I execute dnf with args "makecache --setopt=*.skip_if_unavailable=1"
   Then the exit code is 0
    And stderr is
        """
        Error: Cannot find a valid baseurl for repo: testrepo
        Ignoring repositories: testrepo
        """


@bz1605117
@bz1713627
# reported as https://github.com/rpm-software-management/dnf5/issues/2065
Scenario: Nonexistent GPG key
  Given I use repository "dnf-ci-fedora" with configuration
        | key             | value                                       |
        | gpgkey          | file:///nonexistentkey                      |
        | repo_gpgcheck   | 1                                           |
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr contains "Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///.*/repos/dnf-ci-fedora/repodata/repomd.xml.asc"
    And stderr contains ">>> GPG verification is enabled, but GPG signature is not available. This may be an error or the repository does not support GPG verification:"
   When I execute dnf with args "makecache --setopt=*.skip_if_unavailable=1"
   Then the exit code is 0
    And stderr contains "Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///.*/repos/dnf-ci-fedora/repodata/repomd.xml.asc"
    And stderr contains ">>> GPG verification is enabled, but GPG signature is not available. This may be an error or the repository does not support GPG verification:"
    # See https://github.com/rpm-software-management/dnf5/issues/2064.
    # And stderr contains "Ignoring repositories: dnf-ci-fedora"


@bz1713627
Scenario: Mirrorlist with invalid mirrors
  Given I create file "/tmp/mirrorlist" with
        """
        file:///nonexistent.repo
        http://127.0.0.1:5000/nonexistent
        """
    And I use repository "dnf-ci-fedora" with configuration
        | key             | value                                       |
        | baseurl         |                                             |
        | mirrorlist      | {context.dnf.installroot}/tmp/mirrorlist    |
        | gpgcheck        | 0                                           |
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr matches line by line
    """
    <REPOSYNC>
    >>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///nonexistent.repo/repodata/repomd.xml .*
    >>> Curl error \(7\): (Couldn't|Could not) connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml .*
    >>> Curl error \(7\): (Couldn't|Could not) connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml .*
    >>> Curl error \(7\): (Couldn't|Could not) connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml .*
    >>> Usable URL not found
    Failed to download metadata \(mirrorlist: ".*/tmp/mirrorlist"\) for repository "dnf-ci-fedora": Usable URL not found
    """
   When I execute dnf with args "makecache --setopt=*.skip_if_unavailable=1"
   Then the exit code is 0
    And stderr matches line by line
    """
    <REPOSYNC>
    >>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///nonexistent.repo/repodata/repomd.xml .*
    >>> Curl error \(7\): (Couldn't|Could not) connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml .*
    >>> Curl error \(7\): (Couldn't|Could not) connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml .*
    >>> Curl error \(7\): (Couldn't|Could not) connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml .*
    >>> Usable URL not found
    Repositories loaded.
    """


Scenario: Mirrorlist with invalid mirrors and one good mirror
  Given I create and substitute file "/tmp/mirrorlist" with
        """
        file:///nonexistent.repo
        http://127.0.0.1:5000/nonexistent
        file://{context.scenario.repos_location}/dnf-ci-fedora
        """
    And I use repository "dnf-ci-fedora" with configuration
        | key             | value                                       |
        | baseurl         |                                             |
        | mirrorlist      | {context.dnf.installroot}/tmp/mirrorlist    |
        | gpgcheck        | 0                                           |
   When I execute dnf with args "makecache"
   Then the exit code is 0
    And stdout is
    """
    Metadata cache created.
    """
    And stderr matches line by line
    """
    <REPOSYNC>
    >>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///nonexistent.repo/repodata/repomd.xml .*
    >>> Curl error \(7\): (Couldn't|Could not) connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml .*
    >>> Curl error \(37\): (Couldn't|Could not) read a file:// file for file:///nonexistent.repo/repodata/primary.xml.zst .*
    >>> Curl error \(7\): (Couldn't|Could not) connect to server for http://127.0.0.1:5000/nonexistent/repodata/primary.xml.zst .*
    Repositories loaded.
    """
