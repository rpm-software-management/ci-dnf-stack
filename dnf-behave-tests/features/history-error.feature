Feature: Handling of errors on the history database

Background:
Given I use repository "dnf-ci-fedora"


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


@bz1634385
@no_installroot
Scenario: history database not present under a regular user, who has write permission
Given I successfully execute "chmod o+rwx {context.dnf.tempdir}"
 When I execute dnf with args "--setopt=persistdir={context.dnf.tempdir} repoquery --userinstalled" as an unprivileged user
 Then the exit code is 0
  And stderr is empty
  And file "{context.dnf.tempdir}/history.sqlite" exists


@bz1634385
@no_installroot
Scenario: history database not present under a regular user
 When I execute dnf with args "--setopt=persistdir={context.dnf.tempdir} repoquery --userinstalled" as an unprivileged user
 Then the exit code is 0
  And stderr is
      """
      History database is not readable, using in-memory database instead: Failed to access "{context.dnf.tempdir}/history.sqlite": Permission denied
      """


@bz1761976
@no_installroot
Scenario: read permission error on the history database
Given I successfully execute dnf with args "--setopt=persistdir={context.dnf.tempdir} install abcde"
  And I successfully execute "chmod o-r {context.dnf.tempdir}/history.sqlite"
 When I execute dnf with args "--setopt=persistdir={context.dnf.tempdir} history abcde" as an unprivileged user
 Then the exit code is 0
  And stderr is
      """
      History database is not readable, using in-memory database instead: Failed to access "{context.dnf.tempdir}/history.sqlite": Permission denied
      History database is not readable, using in-memory database instead: Failed to access "{context.dnf.tempdir}/history.sqlite": Permission denied
      """


@bz1761976
@no_installroot
Scenario: read permission error on the history database directory
Given I successfully execute dnf with args "--setopt=persistdir={context.dnf.tempdir} install abcde"
  # executable permission on directory means its contents can't be read
  And I successfully execute "chmod o-x {context.dnf.tempdir}"
 When I execute dnf with args "--setopt=persistdir={context.dnf.tempdir} history abcde" as an unprivileged user
 Then the exit code is 0
  And stderr is
      """
      History database is not readable, using in-memory database instead: Failed to access "{context.dnf.tempdir}/history.sqlite": Permission denied
      History database is not readable, using in-memory database instead: Failed to access "{context.dnf.tempdir}/history.sqlite": Permission denied
      """
