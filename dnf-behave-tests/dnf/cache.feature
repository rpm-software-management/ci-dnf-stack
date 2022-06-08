Feature: Tests for cache


# @dnf5
# TODO(nsella) different stdout
# TODO(nsella) different stderr
@bz1843280
@destructive
@no_installroot
Scenario: Do not error out when fail to load/store expired_repos cache
  Given I use repository "simple-base"
    And I create file "/tmp/dnf/expired_repos.json" with
        """
        """
    And I execute "chmod 777 /tmp/dnf/"
    And I execute "chmod 000 /tmp/dnf/expired_repos.json"
   When I execute dnf with args "repoquery --setopt=cachedir=/tmp/dnf/" as an unprivileged user
   Then the exit code is 0
    And stdout is
        """
        dedalo-signed-0:1.0-1.fc29.src
        dedalo-signed-0:1.0-1.fc29.x86_64
        labirinto-0:1.0-1.fc29.src
        labirinto-0:1.0-1.fc29.x86_64
        vagare-0:1.0-1.fc29.src
        vagare-0:1.0-1.fc29.x86_64
        """
    And stderr contains lines
        """
        Failed to load expired repos cache: [Errno 13] Permission denied: '/tmp/dnf/expired_repos.json'
        Failed to store expired repos cache: [Errno 13] Permission denied: '/tmp/dnf/expired_repos.json'
        """


@not.with_dnf=5
@bz2027445
Scenario: Regenerate solvfile cache when solvfile version doesn't match
  Given I use repository "simple-base"
    And I execute dnf with args "makecache"
   When I invalidate solvfile version of "{context.dnf.installroot}/var/cache/dnf/simple-base.solv"
    And I execute dnf with args "repoquery --setopt=logfilelevel=10"
   Then file "/var/log/hawkey.log" contains lines
        """
        .* DEBUG caching repo: simple-base .*
        """


@not.with_dnf=4
@dnf5
@bz2027445
Scenario: Regenerate solvfile cache when solvfile version doesn't match
  Given I use repository "simple-base"
    And I execute dnf with args "makecache"
   When I invalidate solvfile version of "{context.dnf.installroot}/var/cache/dnf/simple-base-*/solv/simple-base.solv"
    And I execute dnf with args "repoquery"
   Then file "/var/log/dnf5.log" contains lines
        """
        .*WARNING Libsolv solvfile version doesn't match.*
        """
