Feature: Transaction history rollback - comps


Background:
  Given I use repository "dnf-ci-fedora"
    And I use repository "dnf-ci-thirdparty"
    And I successfully execute dnf with args "install setup"
    And I successfully execute dnf with args "group install DNF-CI-Testgroup"
   Then Transaction is following
        | Action        | Package                           |
        | group-install | DNF-CI-Testgroup                  |
        | install-group | filesystem-0:3.9-2.fc29.x86_64    |
        | install-group | lame-0:3.100-4.fc29.x86_64        |
        | install-dep   | lame-libs-0:3.100-4.fc29.x86_64   |
    And History is following
        | Id     | Command                               | Action        | Altered   |
        | 2      | group install DNF-CI-Testgroup        | Install       | 4         |
        | 1      | install setup                         | Install       | 1         |


Scenario: Rollback a transaction that installed a group
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And Transaction is following
        | Action                 | Package                                       |
        | group-remove           | DNF-CI-Testgroup                              |
        | remove                 | filesystem-3.9-2.fc29.x86_64                  |
        | remove                 | lame-0:3.100-4.fc29.x86_64                    |
        | remove-dep             | lame-libs-0:3.100-4.fc29.x86_64               |
    And History is following
        | Id     | Command                               | Action        | Altered   |
        | 3      | history rollback 1                    | Removed       | 4         |
        | 2      | group install DNF-CI-Testgroup        | Install       | 4         |
        | 1      | install setup                         | Install       | 1         |


Scenario: Rollback a transaction that removed a group
  Given I successfully execute dnf with args "group remove DNF-CI-Testgroup"
   When I execute dnf with args "history rollback last-1"
   Then the exit code is 0
    And Transaction is following
        | Action                 | Package                                       |
        | group-install          | DNF-CI-Testgroup                              |
        | install-group          | filesystem-3.9-2.fc29.x86_64                  |
        | install-group          | lame-0:3.100-4.fc29.x86_64                    |
        | install-dep            | lame-libs-0:3.100-4.fc29.x86_64               |
    And History is following
        | Id     | Command                               | Action        | Altered   |
        | 4      | history rollback last-1               | Install       | 4         |
        | 3      | group remove DNF-CI-Testgroup         | Removed       | 4         |
        | 2      | group install DNF-CI-Testgroup        | Install       | 4         |
        | 1      | install setup                         | Install       | 1         |


Scenario: Rollback a transaction with a missing group
  Given I drop repository "dnf-ci-thirdparty"
   When I execute dnf with args "history rollback 1"
   Then the exit code is 1
    And stderr is
    """
    Error: The following problems occurred while running a transaction:
      Group id 'dnf-ci-testgroup' is not available.
    """
