Feature: Tests for the repository syncing functionality


@bz1679509
@bz1692452
Scenario: The default value of skip_if_unavailable is False
  Given I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    reposdir=/testrepos
    """
    And I create file "/testrepos/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=/non/existent/repo
    enabled=1
    gpgcheck=0
    """
    And I do not set config file
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr is
    """
    Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    """


@bz1689931
Scenario: There is global skip_if_unavailable option
  Given I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    reposdir=/testrepos
    skip_if_unavailable=True
    """
    And I create file "/testrepos/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=/non/existent/repo
    enabled=1
    gpgcheck=0
    """
    And I do not set config file
   When I execute dnf with args "makecache"
   Then the exit code is 0
    And stdout matches line by line
    """
    testrepo
    Metadata cache created\.
    """
    And stderr is
    """
    Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    Ignoring repositories: testrepo
    """


Scenario: Per repo skip_if_unavailable configuration
  Given I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    reposdir=/testrepos
    """
    And I create file "/testrepos/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=/non/existent/repo
    enabled=1
    gpgcheck=0
    skip_if_unavailable=True
    """
    And I do not set config file
   When I execute dnf with args "makecache"
   Then the exit code is 0
    And stdout matches line by line
    """
    testrepo
    Metadata cache created\.
    """
    And stderr is
    """
    Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    Ignoring repositories: testrepo
    """


@bz1689931
Scenario: The repo configuration takes precedence over the global one
  Given I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    reposdir=/testrepos
    skip_if_unavailable=True
    """
    And I create file "/testrepos/test.repo" with
    """
    [testrepo]
    name=testrepo
    baseurl=/non/existent/repo
    enabled=1
    gpgcheck=0
    skip_if_unavailable=False
    """
    And I do not set config file
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr is
    """
    Error: Failed to download metadata for repo 'testrepo': Cannot download repomd.xml: Cannot download repodata/repomd.xml: All mirrors were tried
    """


@not.with_os=rhel__eq__8
@bz1741442
Scenario: Test repo_gpgcheck=1 error if repomd.xml.asc is not present
Given I use repository "dnf-ci-fedora" with configuration
      | key           | value |
      | repo_gpgcheck | 1     |
 When I execute dnf with args "makecache"
 Then the exit code is 1
  And stderr contains "Error: Failed to download metadata for repo 'dnf-ci-fedora': GPG verification is enabled, but GPG signature is not available. This may be an error or the repository does not support GPG verification: Curl error \(37\): Couldn't read a file:// file"
