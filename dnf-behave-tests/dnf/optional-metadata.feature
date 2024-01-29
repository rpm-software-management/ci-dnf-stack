Feature: Tests for optional metadata loading functionality


Background:
  Given I use repository "dnf-ci-fedora"
    And I successfully execute dnf with args "makecache"
    And I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
    """
    \.
    \./dnf-ci-fedora-[0-9a-f]{16}
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/primary\.xml\.*
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/repomd\.xml
    \./dnf-ci-fedora\.solv
    \./expired_repos\.json
    """


Scenario: Optional metadata are loaded when explicitly requested by the option
  Given I successfully execute dnf with args "makecache --setopt=optional_metadata_types=filelists"
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
    """
    \.
    \./dnf-ci-fedora-[0-9a-f]{16}
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/filelists\.xml\.zst
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/primary\.xml\.*
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/repomd\.xml
    \./dnf-ci-fedora-filenames\.solvx
    \./dnf-ci-fedora\.solv
    \./expired_repos\.json
    """


Scenario: Invalid metadata type is ignored when processing the option
  Given I successfully execute dnf with args "makecache --setopt=optional_metadata_types=abcdef"
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
    """
    \.
    \./dnf-ci-fedora-[0-9a-f]{16}
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/primary\.xml\.*
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/repomd\.xml
    \./dnf-ci-fedora\.solv
    \./expired_repos\.json
    """


Scenario: Optional metadata are loaded when requested by command
  Given I successfully execute dnf with args "provides basesystem"
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
    """
    \.
    \./dnf-ci-fedora-[0-9a-f]{16}
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/filelists\.xml\.zst
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/primary\.xml\.*
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/repomd\.xml
    \./dnf-ci-fedora-filenames\.solvx
    \./dnf-ci-fedora\.solv
    \./expired_repos\.json
    """


Scenario: Operation returns an error when metadata are not present in cacheonly mode
  Given I execute dnf with args "provides basesystem --cacheonly"
   Then the exit code is 1
    And stderr contains "Error: Cache-only enabled but no cache for 'dnf-ci-fedora'"


Scenario: Filelists metadata are loaded when filepath spec is provided
  Given I successfully execute dnf with args "repoquery /some/file"
   When I execute "find | sort" in "{context.dnf.installroot}/var/cache/dnf"
   Then stdout matches line by line
    """
    \.
    \./dnf-ci-fedora-[0-9a-f]{16}
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/filelists\.xml\.zst
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/primary\.xml\.*
    \./dnf-ci-fedora-[0-9a-f]{16}/repodata/repomd\.xml
    \./dnf-ci-fedora-filenames\.solvx
    \./dnf-ci-fedora\.solv
    \./expired_repos\.json
    """
