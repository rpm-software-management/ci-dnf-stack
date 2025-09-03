Feature: Test --destdir option support on various commands

Scenario Outline: Transactional commands support --destdir option
 When I execute dnf with args "<command> --help"
 Then the exit code is 0
  And stdout contains lines matching
  """
  --destdir=DESTDIR +Set directory used for downloading packages to. Default location is to the repository cache directory. Automatically sets the --downloadonly option.
  """

Examples:
| command           |
| install           |
| upgrade           |
| reinstall         |
| distro-sync       |
| downgrade         |
| do                |
| group install     |
| group upgrade     |


Scenario: Download command supports --destdir option
 When I execute dnf with args "download --help"
 Then the exit code is 0
  And stdout contains lines matching
  """
  --destdir=DESTDIR +Set directory used for downloading packages to. Default location is to the current working directory.
  """


Scenario: Install an RPM with `destdir` option set results in downloadonly transaction
Given I use repository "simple-base"
 When I execute dnf with args "install vagare --destdir={context.dnf.tempdir}/SomeDestination"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                         |
      | install       | vagare-0:1.0-1.fc29.x86_64      |
      | install-dep   | labirinto-0:1.0-1.fc29.x86_64   |
  And RPMDB Transaction is empty
  And stderr contains "The operation will only download packages for the transaction."
 When I execute "find -type f -name '*.rpm' | sort" in "{context.dnf.tempdir}/SomeDestination"
 Then stdout is
 """
 ./labirinto-1.0-1.fc29.x86_64.rpm
 ./vagare-1.0-1.fc29.x86_64.rpm
 """
 # labirinto was already downloaded as vagare dependency, no need to re-download it
 When I execute dnf with args "install labirinto --destdir={context.dnf.tempdir}/SomeDestination"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                         |
      | install       | labirinto-0:1.0-1.fc29.x86_64   |
  And RPMDB Transaction is empty
  And stderr contains "Need to download 0 B."


Scenario: Packages downloaded in download-only transaction with --destdir option are not removed by following transaction
  Given I use repository "simple-base"
   When I execute dnf with args "install labirinto --destdir={context.dnf.tempdir}/SomeDestination --setopt=keepcache=false"
   Then file "/{context.dnf.tempdir}/SomeDestination/labirinto-1.0-1.fc29.x86_64.rpm" exists
   When I execute dnf with args "install labirinto --setopt=keepcache=false"
   Then the exit code is 0
    And Transaction contains
        | Action        | Package                       |
        | install       | labirinto-0:1.0-1.fc29.x86_64 |
    And file "/{context.dnf.tempdir}/SomeDestination/labirinto-1.0-1.fc29.x86_64.rpm" exists
