Feature: Transaction history undo


Background:
  Given I use repository "dnf-ci-fedora"


Scenario: Undoing transactions
  Given I successfully execute dnf with args "install filesystem"
   Then History is following
        | Id     | Command               | Action        | Altered   |
        | 1      | install filesystem    | Install       | 2         |
   When I execute dnf with args "history undo last"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove-dep    | setup-0:2.12.1-1.fc29.noarch               |
        | remove        | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 2      |                       | Removed       | 2         |
        | 1      |                       | Install       | 2         |
   When I execute dnf with args "history undo last"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | install-dep   | setup-0:2.12.1-1.fc29.noarch               |
        | install       | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 3      |                       | Install       | 2         |
        | 2      |                       | Removed       | 2         |
        | 1      |                       | Install       | 2         |
   When I execute dnf with args "history undo last-2"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                                    |
        | remove-dep    | setup-0:2.12.1-1.fc29.noarch               |
        | remove        | filesystem-0:3.9-2.fc29.x86_64             |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 4      |                       | Removed       | 2         |
        | 3      |                       | Install       | 2         |
        | 2      |                       | Removed       | 2         |
        | 1      |                       | Install       | 2         |


@1627111
Scenario: Handle missing packages required for undoing the transaction
    When I execute dnf with args "install wget flac"
    Then the exit code is 0
     And Transaction is following
         | Action        | Package                      |
         | install       | wget-0:1.19.5-5.fc29.x86_64  |
         | install       | flac-0:1.3.2-8.fc29.x86_64   |
   When I drop repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "update"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                      |
        | upgrade       | flac-0:1.3.3-3.fc29.x86_64   |
        | upgrade       | wget-0:1.19.6-5.fc29.x86_64  |
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 2      |                       | Upgrade       | 2         |
        | 1      |                       | Install       | 2         |
     Then I execute dnf with args "history undo 2"
     Then the exit code is 1
     And Transaction is empty
     And stderr is
     """
     Error: The following problems occurred while running a transaction:
       Cannot find rpm nevra "flac-1.3.2-8.fc29.x86_64".
       Cannot find rpm nevra "wget-1.19.5-5.fc29.x86_64".
     """


Scenario: Missing packages are skipped if --skip-unavailable is specified
    When I execute dnf with args "install wget flac"
    Then the exit code is 0
     And Transaction is following
         | Action        | Package                      |
         | install       | wget-0:1.19.5-5.fc29.x86_64  |
         | install       | flac-0:1.3.2-8.fc29.x86_64   |
   When I drop repository "dnf-ci-fedora"
    And I use repository "dnf-ci-fedora-updates"
   Then I execute dnf with args "update"
    Then the exit code is 0
     And Transaction is following
         | Action        | Package                      |
         | upgrade       | flac-0:1.3.3-3.fc29.x86_64   |
         | upgrade       | wget-0:1.19.6-5.fc29.x86_64  |
     Then I execute dnf with args "history undo last --skip-unavailable"
     Then the exit code is 0
     And Transaction is empty
     And stderr is
     """
     Warning, the following problems occurred while running a transaction:
       Cannot find rpm nevra "flac-1.3.2-8.fc29.x86_64".
       Cannot find rpm nevra "wget-1.19.5-5.fc29.x86_64".
     """


Scenario: Undo a transaction with a package that is no longer available
  Given I successfully execute dnf with args "install filesystem"
   When I execute dnf with args "history undo 1 -x filesystem"
   Then the exit code is 1
    And stderr is
    """
    Error: The following problems occurred while running a transaction:
      Cannot find rpm nevra "filesystem-3.9-2.fc29.x86_64".
    """


@bz2010259
@bz2053014
Scenario: Undoing a transaction with Reason Change
  Given I successfully execute dnf with args "install filesystem"
   Then History is following
        | Id     | Command               | Action        | Altered   |
        | 1      | install filesystem    | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | user            |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
   When I execute dnf with args "mark group filesystem"
   Then History is following
        | Id     | Command               | Action        | Altered   |
        | 2      |                       | Reason Change | 1         |
        | 1      | install filesystem    | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | group           |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
   When I execute dnf with args "history undo last"
   Then the exit code is 0
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 3      |                       | Reason Change | 1         |
        | 2      |                       | Reason Change | 1         |
        | 1      |                       | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | user            |
        | setup-2.12.1-1.fc29.noarch   | dependency      |


@bz2010259
@bz2053014
Scenario: Undoing an older transaction with Reason Change
  Given I successfully execute dnf with args "install filesystem"
   Then History is following
        | Id     | Command               | Action        | Altered   |
        | 1      | install filesystem    | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | user            |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
   When I execute dnf with args "mark group filesystem"
   Then History is following
        | Id     | Command               | Action        | Altered   |
        | 2      |                       | Reason Change | 1         |
        | 1      | install filesystem    | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | group           |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
   When I execute dnf with args "install wget"
   Then the exit code is 0
   When I execute dnf with args "history undo last-1"
   Then the exit code is 0
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 4      |                       | Reason Change | 1         |
        | 3      |                       | Install       | 1         |
        | 2      |                       | Reason Change | 1         |
        | 1      |                       | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | user            |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
        | wget-1.19.5-5.fc29.x86_64    | user            |


@bz2010259
@bz2053014
Scenario: Undoing a transaction range with Reason Change
  Given I successfully execute dnf with args "install filesystem"
   Then History is following
        | Id     | Command               | Action        | Altered   |
        | 1      | install filesystem    | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | user            |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
   When I execute dnf with args "mark group filesystem"
   Then History is following
        | Id     | Command               | Action        | Altered   |
        | 2      |                       | Reason Change | 1         |
        | 1      | install filesystem    | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | group           |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
   When I execute dnf with args "install wget"
   Then the exit code is 0
   When I execute dnf with args "history rollback 1"
   Then the exit code is 0
    And History is following
        | Id     | Command               | Action        | Altered   |
        | 4      |                       | C, E          | 2         |
        | 3      |                       | Install       | 1         |
        | 2      |                       | Reason Change | 1         |
        | 1      |                       | Install       | 2         |
    And package reasons are
        | Package                      | Reason          |
        | filesystem-3.9-2.fc29.x86_64 | user            |
        | setup-2.12.1-1.fc29.noarch   | dependency      |
