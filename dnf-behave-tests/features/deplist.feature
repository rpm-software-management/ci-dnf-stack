Feature: Deplist as a commmand and option

Scenario Outline: Deplist as <type>
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "<command> abcde.noarch"
   Then the exit code is 0
    And stdout is
        """
        package: abcde-2.9.2-1.fc29.noarch
          dependency: wget
           provider: wget-1.19.6-5.fc29.src
           provider: wget-1.19.6-5.fc29.x86_64

        package: abcde-2.9.3-1.fc29.noarch
          dependency: wget
           provider: wget-1.19.6-5.fc29.src
           provider: wget-1.19.6-5.fc29.x86_64
        """

Examples:
    | type      | command               |
    | a command | deplist               |
    | an option | repoquery --deplist   |


Scenario: Deplist with --latest-limit
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "repoquery --deplist --latest-limit 1 abcde.noarch"
   Then the exit code is 0
    And stdout is
        """
        package: abcde-2.9.3-1.fc29.noarch
          dependency: wget
           provider: wget-1.19.6-5.fc29.src
           provider: wget-1.19.6-5.fc29.x86_64
        """


Scenario: Deplist with --latest-limit and --verbose
  Given I use the repository "dnf-ci-fedora"
    And I use the repository "dnf-ci-fedora-updates"
   When I execute dnf with args "repoquery --deplist --verbose --latest-limit 1 abcde.noarch"
   Then the exit code is 0
    And stdout contains lines
        """
        package: abcde-2.9.3-1.fc29.noarch
          dependency: wget
           provider: wget-1.19.5-5.fc29.x86_64
           provider: wget-1.19.6-5.fc29.x86_64
        """

