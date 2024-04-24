@use.with_os=fedora__ge__31
Feature: Test the system-upgrade plugin

Background:
  # Install the initial package versions first, then set the (target)
  # releasever and switch the repositories to http (so that system-upgrade
  # actually downloads the packages instead of using the local path). It is not
  # possible to set up an http server for a repository with two different
  # releasever variations.
Given I use repository "system-upgrade-f$releasever" with configuration
      | key         | value |
      | priority    | 1     |
  And I use repository "system-upgrade-2-f$releasever" with configuration
      | key         | value |
      | priority    | 2     |
  And I successfully execute dnf with args "install pkg-a pkg-b pkg-both"
  And I set releasever to "30"
  And I use repository "system-upgrade-f$releasever" as http
  And I use repository "system-upgrade-2-f$releasever" as http
  And I set environment variable "DNF_SYSTEM_UPGRADE_NO_REBOOT" to "1"


@bz2054235
Scenario: Test system-upgrade when reboot wasn't performed
 When I execute dnf with args "system-upgrade download"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |
  And stdout contains lines
      """
      Download complete! Use 'dnf system-upgrade reboot' to start the upgrade.
      To remove cached metadata and transaction use 'dnf system-upgrade clean'
      The downloaded packages were saved in cache until the next successful transaction.
      You can remove cached packages by executing 'dnf clean packages'.
      """
 When I execute dnf with args "system-upgrade upgrade"
 Then the exit code is 0
  And stdout is
      """
      trigger file does not exist. exiting quietly.
      """


@bz2054235
Scenario: Test system-upgrade basic functionality
 When I execute dnf with args "system-upgrade download"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |
  And stdout contains lines
      """
      Download complete! Use 'dnf system-upgrade reboot' to start the upgrade.
      To remove cached metadata and transaction use 'dnf system-upgrade clean'
      The downloaded packages were saved in cache until the next successful transaction.
      You can remove cached packages by executing 'dnf clean packages'.
      """
Given I successfully execute dnf with args "system-upgrade reboot"
  And I stop http server for repository "system-upgrade-f$releasever"
  And I stop http server for repository "system-upgrade-2-f$releasever"
 When I execute dnf with args "system-upgrade upgrade"
 Then the exit code is 0
  And transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |


@bz2054235
Scenario: Test system-upgrade with --destdir
 When I execute dnf with args "system-upgrade download --destdir={context.dnf.tempdir}/destdir"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |
  And stdout contains lines
      """
      Download complete! Use 'dnf system-upgrade reboot' to start the upgrade.
      To remove cached metadata and transaction use 'dnf system-upgrade clean'
      The downloaded packages were saved in cache until the next successful transaction.
      You can remove cached packages by executing 'dnf clean packages'.
      """
Given I successfully execute dnf with args "system-upgrade reboot"
  And I stop http server for repository "system-upgrade-f$releasever"
  And I stop http server for repository "system-upgrade-2-f$releasever"
 When I execute dnf with args "system-upgrade upgrade"
 Then the exit code is 0
  And transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |


@bz2054235
Scenario: Test system-upgrade with --no-downgrade
 When I execute dnf with args "system-upgrade download --no-downgrade"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
  And stdout contains lines
      """
      Download complete! Use 'dnf system-upgrade reboot' to start the upgrade.
      To remove cached metadata and transaction use 'dnf system-upgrade clean'
      The downloaded packages were saved in cache until the next successful transaction.
      You can remove cached packages by executing 'dnf clean packages'.
      """
Given I successfully execute dnf with args "system-upgrade reboot"
  And I stop http server for repository "system-upgrade-f$releasever"
  And I stop http server for repository "system-upgrade-2-f$releasever"
 When I execute dnf with args "system-upgrade upgrade"
 Then the exit code is 0
  And transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |


@bz2054235
Scenario: Test system-upgrade transaction file not found
 When I execute dnf with args "system-upgrade download"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |
  And stdout contains lines
      """
      Download complete! Use 'dnf system-upgrade reboot' to start the upgrade.
      To remove cached metadata and transaction use 'dnf system-upgrade clean'
      The downloaded packages were saved in cache until the next successful transaction.
      You can remove cached packages by executing 'dnf clean packages'.
      """
Given I successfully execute dnf with args "system-upgrade reboot"
  And I delete file "/var/lib/dnf/system-upgrade/system-upgrade-transaction.json"
 When I execute dnf with args "system-upgrade upgrade"
 Then the exit code is 1
  And stderr is
      """
      [Errno 2] No such file or directory: '{context.dnf.installroot}/var/lib/dnf/system-upgrade/system-upgrade-transaction.json'
      """


@bz2054235
Scenario: Test system-upgrade downloading a package from a different repo
 When I execute dnf with args "system-upgrade download"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |
  And stdout contains lines
      """
      Download complete! Use 'dnf system-upgrade reboot' to start the upgrade.
      To remove cached metadata and transaction use 'dnf system-upgrade clean'
      The downloaded packages were saved in cache until the next successful transaction.
      You can remove cached packages by executing 'dnf clean packages'.
      """
Given I successfully execute dnf with args "system-upgrade reboot"
# Swap the priorities, so that dnf attempts to install the package from the other repo
  And I configure repository "system-upgrade-f$releasever" with
      | key         | value |
      | priority    | 2     |
  And I configure repository "system-upgrade-2-f$releasever" with
      | key         | value |
      | priority    | 1     |
  And I stop http server for repository "system-upgrade-f$releasever"
  And I stop http server for repository "system-upgrade-2-f$releasever"
 When I execute dnf with args "system-upgrade upgrade"
 Then the exit code is 0
  And transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |


@bz2054235
Scenario: Test system-upgrade empty transaction
Given I successfully execute dnf with args "distro-sync"
 When I execute dnf with args "system-upgrade download"
 Then the exit code is 0
  And DNF Transaction is empty
  And stdout contains lines
      """
      The system-upgrade transaction is empty, your system is already up-to-date.
      """
 When I execute dnf with args "system-upgrade reboot"
 Then the exit code is 1
  And stderr is
      """
      Error: system is not ready for upgrade
      """


@bz2054235
@bz2024430
Scenario Outline: Test system-upgrade with <option> doesn't delete user files
Given I create directory "/downloaddir"
  And I create file "/downloaddir/precious_file1" with
      """
      precious content1
      """
  And I create directory "/downloaddir/precious_dir"
  And I create file "/downloaddir/precious_dir/precious_file2" with
      """
      precious content2
      """
  And I execute dnf with args "system-upgrade download <option>={context.dnf.installroot}/downloaddir"
  And I successfully execute dnf with args "system-upgrade reboot"
  And I stop http server for repository "system-upgrade-f$releasever"
  And I stop http server for repository "system-upgrade-2-f$releasever"
 When I execute dnf with args "system-upgrade upgrade"
 Then the exit code is 0
  And transaction is following
      | Action        | Package               |
      | upgrade       | pkg-a-2.0-1.noarch    |
      | upgrade       | pkg-both-2.0-1.noarch |
      | downgrade     | pkg-b-1.0-1.noarch    |
  And file "/downloaddir/precious_file1" exists
  And file "/downloaddir/precious_dir/precious_file2" exists
  And file "/downloaddir/pkg-a-2.0-1.noarch.rpm" does not exist
  And file "/downloaddir/pkg-b-1.0-1.noarch.rpm" does not exist
  And file "/downloaddir/pkg-both-2.0-1.noarch.rpm" does not exist

Examples:
      | option            |
      | --destdir         |
      | --downloaddir     |
      | --setopt=cachedir |
      # cachedir cannot be overwritten by user in system-upgrade, but test it to make sure
