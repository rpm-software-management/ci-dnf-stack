Feature: Transaction history rollback of environment upgrades


Background:
  Given I use repository "dnf-ci-group-rollback-1"
    And I successfully execute dnf with args "group install DNF-CI-RollbackTestEnv"
   Then Transaction is following
        | Action        | Package                                       |
        | env-install   | DNF-CI-RollbackTestEnv                        |
        | group-install | DNF-CI-RollbackTestGroup1                     |
        | group-install | DNF-CI-RollbackTestGroup2                     |
        | install-group | TestGroup1PackageA-0:1.0-1.x86_64             |
        | install-group | TestGroup1PackageB-0:1.0-1.x86_64             |
        | install-group | TestGroup2PackageA-0:1.0-1.x86_64             |
        | install-group | TestGroup2PackageB-0:1.0-1.x86_64             |
    And History is following
        | Id     | Command                                              | Action        | Altered   |
        | 1      | group install DNF-CI-RollbackTestEnv                 | Install       | 7         |
  Given I use repository "dnf-ci-group-rollback-2"
    And I successfully execute dnf with args "group upgrade DNF-CI-RollbackTestEnv"
   Then Transaction is following
        | Action        | Package                                       |
        | env-upgrade   | DNF-CI-RollbackTestEnv                        |
        | group-upgrade | DNF-CI-RollbackTestGroup1                     |
        | group-upgrade | DNF-CI-RollbackTestGroup2                     |
        | upgrade       | TestGroup1PackageA-0:1.1-1.x86_64             |
        | upgrade       | TestGroup1PackageB-0:1.1-1.x86_64             |
        | upgrade       | TestGroup2PackageA-0:1.1-1.x86_64             |
        | upgrade       | TestGroup2PackageB-0:1.1-1.x86_64             |
    And History is following
        | Id     | Command                                              | Action        | Altered   |
        | 2      | group upgrade DNF-CI-RollbackTestEnv                 | Upgrade       | 7         |
        | 1      | group install DNF-CI-RollbackTestEnv                 | Install       | 7         |


@bz2016070
Scenario: Rollback an environment upgrade transaction
  Given I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action                 | Package                              |
        | downgrade              | TestGroup1PackageA-0:1.0-1.x86_64    |
        | downgrade              | TestGroup1PackageB-0:1.0-1.x86_64    |
        | downgrade              | TestGroup2PackageA-0:1.0-1.x86_64    |
        | downgrade              | TestGroup2PackageB-0:1.0-1.x86_64    |
    And History is following
        | Id     | Command                                              | Action        | Altered   |
        | 3      | history rollback 1                                   | Downgrade     | 7         |
        | 2      | group upgrade DNF-CI-RollbackTestEnv                 | Upgrade       | 7         |
        | 1      | group install DNF-CI-RollbackTestEnv                 | Install       | 7         |
