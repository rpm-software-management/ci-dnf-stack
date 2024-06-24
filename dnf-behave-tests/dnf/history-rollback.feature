@dnf5
Feature: Transaction history rollback


Background:
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
    And I successfully execute dnf with args "install basesystem"
    And I successfully execute dnf with args "install glibc-2.28-26.fc29.x86_64"
    And I successfully execute dnf with args "downgrade glibc"
    And I successfully execute dnf with args "upgrade glibc"


Scenario: Rollback
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | glibc-2.28-26.fc29.x86_64                  |
        | remove-unused | glibc-all-langpacks-2.28-26.fc29.x86_64    |
        | remove-unused | glibc-common-2.28-26.fc29.x86_64           |


Scenario: Multiple rollbacks
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove        | glibc-2.28-26.fc29.x86_64                  |
        | remove-unused | glibc-all-langpacks-2.28-26.fc29.x86_64    |
        | remove-unused | glibc-common-2.28-26.fc29.x86_64           |
   When I execute dnf with args "history rollback 2"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install       | glibc-2.28-26.fc29.x86_64                  |
        | install-dep   | glibc-all-langpacks-2.28-26.fc29.x86_64    |
        | install-dep   | glibc-common-2.28-26.fc29.x86_64           |


Scenario: Rollback a transaction with a package that is no longer available
   When I execute dnf with args "history rollback 1 -x glibc-2.28-26.fc29.x86_64"
   Then the exit code is 1
    And stderr is
    """
    Failed to resolve the transaction:
    Cannot perform Remove action because 'glibc-2.28-26.fc29.x86_64' matches only excluded packages.
    Problem: installed package glibc-2.28-26.fc29.x86_64 requires glibc-common = 2.28-26.fc29, but none of the providers can be installed
      - conflicting requests
      - problem with installed package
    """
