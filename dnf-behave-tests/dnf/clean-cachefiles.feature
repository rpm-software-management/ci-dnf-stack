@dnf5
@dnf5daemon
Feature: Testing that dnf clean command removes files from the cache


Background: Fill the cache
  Given I use repository "simple-base" as http
   When I execute dnf with args "--setopt=keepcache=true install labirinto"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | labirinto-0:1.0-1.fc29.x86_64             |
   # ensure that metadata are present
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
   """
   \.
   \./simple-base-[0-9a-f]{16}
   \./simple-base-[0-9a-f]{16}/packages
   \./simple-base-[0-9a-f]{16}/packages/labirinto-1\.0-1\.fc29\.x86_64\.rpm
   \./simple-base-[0-9a-f]{16}/repodata
   \./simple-base-[0-9a-f]{16}/repodata/primary\.xml\.zst
   \./simple-base-[0-9a-f]{16}/repodata/repomd\.xml
   \./simple-base-[0-9a-f]{16}/solv
   \./simple-base-[0-9a-f]{16}/solv/simple-base\.solv
   """


Scenario: Cleanup of the whole cache (dnf clean all)
   When I execute dnf with args "clean all"
   Then the exit code is 0
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
   """
   \.
   """


Scenario: Cached metadata cleanup (dnf clean metadata)
   When I execute dnf with args "clean metadata"
   Then the exit code is 0
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
   """
   \.
   \./simple-base-[0-9a-f]{16}
   \./simple-base-[0-9a-f]{16}/packages
   \./simple-base-[0-9a-f]{16}/packages/labirinto-1\.0-1\.fc29\.x86_64\.rpm
   """


Scenario: Cached packages cleanup (dnf clean packages)
   When I execute dnf with args "clean packages"
   Then the exit code is 0
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
   """
   \.
   \./simple-base-[0-9a-f]{16}
   \./simple-base-[0-9a-f]{16}/repodata
   \./simple-base-[0-9a-f]{16}/repodata/primary\.xml\.zst
   \./simple-base-[0-9a-f]{16}/repodata/repomd\.xml
   \./simple-base-[0-9a-f]{16}/solv
   \./simple-base-[0-9a-f]{16}/solv/simple-base\.solv
   """


Scenario: Database cached cleanup (dnf clean dbcache)
   When I execute dnf with args "clean dbcache"
   Then the exit code is 0
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
   """
   \.
   \./simple-base-[0-9a-f]{16}
   \./simple-base-[0-9a-f]{16}/packages
   \./simple-base-[0-9a-f]{16}/packages/labirinto-1\.0-1\.fc29\.x86_64\.rpm
   \./simple-base-[0-9a-f]{16}/repodata
   \./simple-base-[0-9a-f]{16}/repodata/primary\.xml\.zst
   \./simple-base-[0-9a-f]{16}/repodata/repomd\.xml
   """
