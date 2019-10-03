Feature: Check when there are multiple problems


Background: Force installation of an RPM that will cause problems with dependencies, duplicates and obsoletes
  Given I use repository "dnf-ci-fedora"
   When I execute dnf with args "install glibc"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                   |
        | install       | setup-0:2.12.1-1.fc29.noarch              |
        | install       | filesystem-0:3.9-2.fc29.x86_64            |
        | install       | basesystem-0:11-6.fc29.noarch             |
        | install       | glibc-0:2.28-9.fc29.x86_64                |
        | install       | glibc-common-0:2.28-9.fc29.x86_64         |
        | install       | glibc-all-langpacks-0:2.28-9.fc29.x86_64  |
   When I execute rpm with args "-i --nodeps {context.dnf.fixturesdir}/repos/dnf-ci-fedora-updates/x86_64/glibc-2.28-26.fc29.x86_64.rpm"
   Then the exit code is 0


Scenario: Check
   When I execute dnf with args "check"
   Then the exit code is 1
    And stdout contains "glibc-2.28-9.fc29.x86_64 is a duplicate with glibc-2.28-26.fc29.x86_64"
    And stdout contains "glibc-2.28-9.fc29.x86_64 is obsoleted by glibc-2.28-26.fc29.x86_64"
    And stdout contains "glibc-2.28-26.fc29.x86_64 has missing requires of glibc-common = 2.28-26.fc29"
    And stdout contains "glibc-2.28-26.fc29.x86_64 has missing requires of glibc-langpack = 2.28-26.fc29"
    And stderr is
        """
        Error: Check discovered 4 problem(s)
        """

Scenario: Check all
   When I execute dnf with args "check all"
   Then the exit code is 1
    And stdout contains "glibc-2.28-9.fc29.x86_64 is a duplicate with glibc-2.28-26.fc29.x86_64"
    And stdout contains "glibc-2.28-9.fc29.x86_64 is obsoleted by glibc-2.28-26.fc29.x86_64"
    And stdout contains "glibc-2.28-26.fc29.x86_64 has missing requires of glibc-common = 2.28-26.fc29"
    And stdout contains "glibc-2.28-26.fc29.x86_64 has missing requires of glibc-langpack = 2.28-26.fc29"
    And stderr is
        """
        Error: Check discovered 4 problem(s)
        """

Scenario: Check --dependencies
   When I execute dnf with args "check --dependencies"
   Then the exit code is 1
    And stdout contains "glibc-2.28-26.fc29.x86_64 has missing requires of glibc-common = 2.28-26.fc29"
    And stdout contains "glibc-2.28-26.fc29.x86_64 has missing requires of glibc-langpack = 2.28-26.fc29"
    And stderr is
        """
        Error: Check discovered 2 problem(s)
        """


Scenario: Check --duplicates
   When I execute dnf with args "check --duplicates"
   Then the exit code is 1
    And stdout contains "glibc-2.28-9.fc29.x86_64 is a duplicate with glibc-2.28-26.fc29.x86_64"
    And stderr is
        """
        Error: Check discovered 1 problem(s)
        """


Scenario: Check --obsoleted
   When I execute dnf with args "check --obsoleted"
   Then the exit code is 1
    And stdout contains "glibc-2.28-9.fc29.x86_64 is obsoleted by glibc-2.28-26.fc29.x86_64"
    And stderr is
        """
        Error: Check discovered 1 problem(s)
        """


Scenario: Check --provides
   When I execute dnf with args "check --provides"
   Then the exit code is 0
    And stdout is empty
    And stderr is empty
