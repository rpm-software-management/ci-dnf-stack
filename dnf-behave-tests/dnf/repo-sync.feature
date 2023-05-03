# @dnf5
# TODO(nsella) Unknown argument "makecache" for command "microdnf"
Feature: Tests for the repository syncing functionality

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
    And stderr is
    """
    Errors during downloading metadata for repository 'testrepo':
      - Curl error (37): Couldn't read a file:// file for file:///non/existent/repo/repodata/repomd.xml [Couldn't open file /non/existent/repo/repodata/repomd.xml]
    Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
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
    And stdout matches line by line
    """
    testrepo
    Metadata cache created\.
    """
    And stderr is
    """
    Errors during downloading metadata for repository 'testrepo':
      - Curl error (37): Couldn't read a file:// file for file:///non/existent/repo/repodata/repomd.xml [Couldn't open file /non/existent/repo/repodata/repomd.xml]
    Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    Ignoring repositories: testrepo
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
    And stdout matches line by line
    """
    testrepo
    Metadata cache created\.
    """
    And stderr is
    """
    Errors during downloading metadata for repository 'testrepo':
      - Curl error (37): Couldn't read a file:// file for file:///non/existent/repo/repodata/repomd.xml [Couldn't open file /non/existent/repo/repodata/repomd.xml]
    Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    Ignoring repositories: testrepo
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
    And stderr is
    """
    Errors during downloading metadata for repository 'testrepo':
      - Curl error (37): Couldn't read a file:// file for file:///non/existent/repo/repodata/repomd.xml [Couldn't open file /non/existent/repo/repodata/repomd.xml]
    Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    """


@bz1741442
@bz1752362
Scenario: Test repo_gpgcheck=1 error if repomd.xml.asc is not present
Given I use repository "dnf-ci-fedora" with configuration
      | key           | value |
      | repo_gpgcheck | 1     |
 When I execute dnf with args "makecache"
 Then the exit code is 1
  And stderr contains "Errors during downloading metadata for repository 'dnf-ci-fedora':"
  And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for file://.*/dnf-ci-fedora/repodata/repomd.xml.asc \[Couldn't open file .*/dnf-ci-fedora/repodata/repomd.xml.asc\]"
  And stderr contains "Error: Failed to download metadata for repo 'dnf-ci-fedora': GPG verification is enabled, but GPG signature is not available. This may be an error or the repository does not support GPG verification: Curl error \(37\): Couldn't read a file:// file for file://.*/dnf-ci-fedora/repodata/repomd.xml.asc \[Couldn't open file .*/dnf-ci-fedora/repodata/repomd.xml.asc\]"


@bz1713627
Scenario: Missing baseurl/metalink/mirrorlist
  Given I configure a new repository "testrepo" with
        | key      | value        |
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr is
        """
        Error: Cannot find a valid baseurl for repo: testrepo
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
Scenario: Nonexistent GPG key
  Given I use repository "dnf-ci-fedora" with configuration
        | key             | value                                       |
        | gpgkey          | file:///nonexistentkey                      |
        | repo_gpgcheck   | 1                                           |
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr contains "Errors during downloading metadata for repository 'dnf-ci-fedora':"
    And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for file:///nonexistentkey \[Couldn't open file /nonexistentkey\]"
    And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for .*repomd.xml.asc \[Couldn't open file .*repomd.xml.asc\]"
    And stderr contains "Error: Failed to retrieve GPG key for repo 'dnf-ci-fedora'"
   When I execute dnf with args "makecache --setopt=*.skip_if_unavailable=1"
   Then the exit code is 0
    And stderr contains "Errors during downloading metadata for repository 'dnf-ci-fedora':"
    And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for file:///nonexistentkey \[Couldn't open file /nonexistentkey\]"
    And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for .*repomd.xml.asc \[Couldn't open file .*repomd.xml.asc\]"
    And stderr contains "Error: Failed to retrieve GPG key for repo 'dnf-ci-fedora'"
    And stderr contains "Ignoring repositories: dnf-ci-fedora"


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
    And stderr contains "Errors during downloading metadata for repository 'dnf-ci-fedora':"
    And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for file:///nonexistent.repo/repodata/repomd.xml \[Couldn't open file /nonexistent.repo/repodata/repomd.xml\]"
    And stderr contains "  - Curl error \(7\): Couldn't connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml \[Failed to connect to 127.0.0.1 port 5000 after 0 ms: Couldn't connect to server\]"
    And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for file:///nonexistent.repo/repodata/repomd.xml \[Couldn't open file /nonexistent.repo/repodata/repomd.xml\]"
    And stderr contains "Error: Failed to download metadata for repo 'dnf-ci-fedora': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried"
   When I execute dnf with args "makecache --setopt=*.skip_if_unavailable=1"
   Then the exit code is 0
    And stderr contains "Errors during downloading metadata for repository 'dnf-ci-fedora':"
    And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for file:///nonexistent.repo/repodata/repomd.xml \[Couldn't open file /nonexistent.repo/repodata/repomd.xml\]"
    And stderr contains "  - Curl error \(7\): Couldn't connect to server for http://127.0.0.1:5000/nonexistent/repodata/repomd.xml \[Failed to connect to 127.0.0.1 port 5000 after 0 ms: Couldn't connect to server\]"
    And stderr contains "  - Curl error \(37\): Couldn't read a file:// file for file:///nonexistent.repo/repodata/repomd.xml \[Couldn't open file /nonexistent.repo/repodata/repomd.xml\]"
    And stderr contains "Error: Failed to download metadata for repo 'dnf-ci-fedora': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried"
    And stderr contains "Ignoring repositories: dnf-ci-fedora"


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
    And stderr is empty
