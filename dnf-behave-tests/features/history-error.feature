Feature: Handling of errors on the history database


Scenario: history list on a broken history database
Given I create file "/var/lib/dnf/history.sqlite" with
      """
      GARBAGE
      """
 When I execute dnf with args "history filesystem"
 Then the exit code is 1
  And stderr is
      """
      History database is not writable: SQLite error on "{context.dnf.installroot}/var/lib/dnf/history.sqlite": Executing an SQL statement failed: file is not a database
      Error: SQLite error on "{context.dnf.installroot}/var/lib/dnf/history.sqlite": Executing an SQL statement failed: file is not a database
      """


Scenario: install with a broken history database
Given I use repository "dnf-ci-fedora"
  And I create file "/var/lib/dnf/history.sqlite" with
      """
      GARBAGE
      """
 When I execute dnf with args "install filesystem"
 Then the exit code is 1
  And stderr is
      """
      History database is not writable: SQLite error on "{context.dnf.installroot}/var/lib/dnf/history.sqlite": Executing an SQL statement failed: file is not a database
      History database is not writable: SQLite error on "{context.dnf.installroot}/var/lib/dnf/history.sqlite": Executing an SQL statement failed: file is not a database
      Error: SQLite error on "{context.dnf.installroot}/var/lib/dnf/history.sqlite": Executing an SQL statement failed: file is not a database
      """
