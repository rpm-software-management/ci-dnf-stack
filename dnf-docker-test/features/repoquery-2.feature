Feature: Test for main repoquery functionality
  for options --requires, --provides, --conflicts, --obsoletes,
  --whatrequires, --whatprovides, --whatconflicts, --whatobsoletes

  @setup
  Scenario: Feature Setup
      Given repository "base" with packages
        | Package | Tag       | Value |
        | TestA   | Version   | 1     |
        |         | Release   | 1     |
        |         | Requires  | TestB |
        |         | Provides  | TestC |
        |         | Conflicts | TestD |
        |         | Obsoletes | TestE |
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf makecache"

  Scenario: repoquery --requires
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -q repoquery --requires TestA"
       Then the command stdout should match exactly
            """
            TestB

            """

  Scenario: repoquery --provides
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -q repoquery --provides TestA"
       Then the command stdout should match exactly
            """
            TestA = 1-1
            TestC

            """

  Scenario: repoquery --conflicts
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -q repoquery --conflicts TestA"
       Then the command stdout should match exactly
            """
            TestD

            """

  Scenario: repoquery --obsoletes
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -q repoquery --obsoletes TestA"
       Then the command stdout should match exactly
            """
            TestE

            """

  Scenario: repoquery --whatrequires
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -q repoquery --whatrequires TestB"
       Then the command stdout should match exactly
            """
            TestA-0:1-1.noarch

            """

  Scenario: repoquery --whatprovides
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -q repoquery --whatprovides TestC"
       Then the command stdout should match exactly
            """
            TestA-0:1-1.noarch

            """

  Scenario: repoquery --whatconflicts
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -q repoquery --whatconflicts TestD"
       Then the command stdout should match exactly
            """
            TestA-0:1-1.noarch

            """

  Scenario: repoquery --whatobsoletes
       When I save rpmdb
        And I enable repository "base"
        And I run "dnf -q repoquery --whatobsoletes TestE"
       Then the command stdout should match exactly
            """
            TestA-0:1-1.noarch

            """
