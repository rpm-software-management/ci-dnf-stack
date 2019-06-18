Feature: Test skip_if_unavailable default value and global/repo options


@bz1679509
@bz1692452
Scenario: The default value of skip_if_unavailable is False
  Given I use the repository "testrepo"
    And I create file "/etc/dnf/dnf.conf" with
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
    And I do not set reposdir
    And I do not set config file
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr is
    """
    Failed to download metadata for repo 'testrepo'
    Error: Failed to download metadata for repo 'testrepo'
    """


@bz1689931
Scenario: There is global skip_if_unavailable option
  Given I use the repository "testrepo"
    And I create file "/etc/dnf/dnf.conf" with
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
    And I do not set reposdir
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
    Failed to download metadata for repo 'testrepo'
    Ignoring repositories: testrepo
    """


Scenario: Per repo skip_if_unavailable configuration
  Given I use the repository "testrepo"
    And I create file "/etc/dnf/dnf.conf" with
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
    And I do not set reposdir
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
    Failed to download metadata for repo 'testrepo'
    Ignoring repositories: testrepo
    """


@bz1689931
Scenario: The repo configuration takes precedence over the global one
  Given I use the repository "testrepo"
    And I create file "/etc/dnf/dnf.conf" with
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
    And I do not set reposdir
    And I do not set config file
   When I execute dnf with args "makecache"
   Then the exit code is 1
    And stderr is
    """
    Failed to download metadata for repo 'testrepo'
    Error: Failed to download metadata for repo 'testrepo'
    """
