Feature: Tests for cache


@bz1843280
@destructive
@no_installroot
Scenario: Do not error out when fail to load/store expired_repos cache
  Given I use repository "miscellaneous"
    And I create file "/tmp/dnf/expired_repos.json" with
        """
        """
    And I execute "chmod 777 /tmp/dnf/"
    And I execute "chmod 000 /tmp/dnf/expired_repos.json"
   When I execute dnf with args "repoquery --setopt=cachedir=/tmp/dnf/" as an unprivileged user
   Then the exit code is 0
    And stdout is
        """
        dummy-1:1.0-1.src
        dummy-1:1.0-1.x86_64
        weird-1:1.0-1.src
        weird-1:1.0-1.x86_64
        weird-1:2.0-1.src
        weird-1:2.0-1.x86_64
        """
    And stderr contains lines
        """
        Failed to load expired repos cache: [Errno 13] Permission denied: '/tmp/dnf/expired_repos.json'
        Failed to store expired repos cache: [Errno 13] Permission denied: '/tmp/dnf/expired_repos.json'
        """
