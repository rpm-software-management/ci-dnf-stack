@xfail
Feature: Deplist as commmand and option

  Scenario: Feature Setup
      Given I use the repository "upgrade_1"

  Scenario: Deplist as command
       When I successfully run "yum deplist TestA"
       Then the command stdout should contain exactly
            """
            package: TestA-1.0.0-1.noarch
              dependency: TestB
               provider: TestB-1.0.0-2.noarch

            package: TestA-1.0.0-2.noarch
              dependency: TestB
               provider: TestB-1.0.0-2.noarch

            """

  Scenario: Deplist as repoquery option
       When I successfully run "dnf repoquery --deplist TestA"
       Then the command stdout should contain exactly
            """
            package: TestA-1.0.0-1.noarch
              dependency: TestB
               provider: TestB-1.0.0-2.noarch

            package: TestA-1.0.0-2.noarch
              dependency: TestB
               provider: TestB-1.0.0-2.noarch

            """

  Scenario: Deplist as repoquery option but using dnf bin
       When I successfully run "sh -c 'dnf repoquery --deplist TestA'"
       Then the command stdout should contain exactly
            """
            package: TestA-1.0.0-1.noarch
              dependency: TestB
               provider: TestB-1.0.0-2.noarch

            package: TestA-1.0.0-2.noarch
              dependency: TestB
               provider: TestB-1.0.0-2.noarch

            """

  Scenario: Deplist with --latest-limit
       When I successfully run "dnf repoquery --deplist --latest-limit 1 TestA"
       Then the command stdout should contain exactly
            """
            package: TestA-1.0.0-2.noarch
              dependency: TestB
               provider: TestB-1.0.0-2.noarch

            """

  Scenario: Deplist with --latest-limit and verbose
       When I execute "dnf" command "repoquery --deplist --latest-limit 1 --verbose TestA" with "success"
       Then line from "stdout" should "start" with "package: TestA-1.0.0-2.noarch"
       And line from "stdout" should "start" with "  dependency: TestB"
       And line from "stdout" should "start" with "   provider: TestB-1.0.0-1.noarch"
       And line from "stdout" should "start" with "   provider: TestB-1.0.0-2.noarch"
