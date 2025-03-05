Feature: Test the offline command

Background:
Given I use repository "dnf-ci-fedora"
  And I successfully execute dnf with args "install glibc"
  And I set environment variable "DNF_SYSTEM_UPGRADE_NO_REBOOT" to "1"


Scenario: Test offline when reboot wasn't performed
 When I execute dnf with args "install --offline flac"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                    |
      | install       | flac-0:1.3.2-8.fc29.x86_64 |
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.
      """
 When I execute dnf with args "offline _execute"
 Then the exit code is 0
  And stderr contains lines
      """
      Trigger file does not exist. Exiting.
      """


Scenario: Test offline when an offline transaction is already queued
 When I execute dnf with args "install --offline flac"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                    |
      | install       | flac-0:1.3.2-8.fc29.x86_64 |
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.
      """
 When I execute dnf with args "install --offline flac"
 Then the exit code is 0
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.

      There is already an offline transaction queued, initiated by the following command:
      Continuing will cancel the old offline transaction and replace it with this one.
      """


Scenario: Test offline when offline-transaction-state.toml has wrong state version
Given I create file "/usr/lib/sysimage/libdnf5/offline/offline-transaction-state.toml" with
    """
    [offline-transaction-state]
    module_platform_id = ""
    disabled_repos = []
    enabled_repos = []
    poweroff_after = false
    verb = "install"
    system_releasever = "39"
    target_releasever = "39"
    cachedir = ""
    status = "download-complete"
    cmd_line = ""
    state_version = -1
    """
 When I execute dnf with args "offline reboot"
 Then the exit code is 1
  And stderr contains lines
      """
      Error reading state: incompatible version of state data. Rerun the command you used to initiate the offline transaction, e.g. `dnf5 system-upgrade download [OPTIONS]`.
      """


Scenario: Test offline clean
 When I execute dnf with args "install --offline flac"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                    |
      | install       | flac-0:1.3.2-8.fc29.x86_64 |
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.
      """
Given I successfully execute dnf with args "offline reboot"
  And file "/usr/lib/sysimage/libdnf5/offline/offline-transaction-state.toml" exists
  And file "/usr/lib/sysimage/libdnf5/offline/transaction.json" exists
 When I execute dnf with args "offline clean"
 Then the exit code is 0
  And directory "/usr/lib/sysimage/libdnf5/offline" is empty


Scenario: Test offline install and offline status
 When I execute dnf with args "offline status"
 Then the exit code is 0
  And stdout contains lines
      """
      No offline transaction is stored.
      """
 When I execute dnf with args "install --offline flac"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                    |
      | install       | flac-0:1.3.2-8.fc29.x86_64 |
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.
      """
 When I execute dnf with args "offline status"
 Then the exit code is 0
  And stdout contains lines
      """
      An offline transaction was initiated by the following command:
      Run `dnf5 offline reboot` to reboot and perform the offline transaction.
      """
Given I successfully execute dnf with args "offline reboot"
 When I execute dnf with args "offline _execute"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                    |
      | install       | flac-0:1.3.2-8.fc29.x86_64 |
 When I execute dnf with args "offline status"
 Then the exit code is 0
  And stdout contains lines
      """
      No offline transaction is stored.
      """


Scenario: Test offline upgrade
Given I use repository "dnf-ci-fedora-updates"
 When I execute dnf with args "upgrade --offline"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                                   |
      | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
      | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
      | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.
      """
Given I successfully execute dnf with args "offline reboot"
 When I execute dnf with args "offline _execute"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                                   |
      | upgrade       | glibc-0:2.28-26.fc29.x86_64               |
      | upgrade       | glibc-common-0:2.28-26.fc29.x86_64        |
      | upgrade       | glibc-all-langpacks-0:2.28-26.fc29.x86_64 |


Scenario: Test offline group install
Given I use repository "dnf-ci-thirdparty"
 When I execute dnf with args "group install --offline dnf-ci-testgroup"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                           |
      | install-group | lame-0:3.100-4.fc29.x86_64        |
      | install-dep   | lame-libs-0:3.100-4.fc29.x86_64   |
      | group-install | DNF-CI-Testgroup                  |
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.
      """
Given I successfully execute dnf with args "offline reboot"
 When I execute dnf with args "offline _execute"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                           |
      | install-group | lame-0:3.100-4.fc29.x86_64        |
      | install-dep   | lame-libs-0:3.100-4.fc29.x86_64   |
      | group-install | DNF-CI-Testgroup                  |


Scenario: Test offline-distrosync
Given I use repository "simple-base"
  And I execute dnf with args "install labirinto"
  And I use repository "simple-updates"
 When I execute dnf with args "offline-distrosync download"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                               |
      | upgrade       | labirinto-2.0-1.fc29.x86_64           |
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.
      """
 When I execute dnf with args "offline-distrosync status"
 Then the exit code is 0
  And stdout contains lines
      """
      An offline transaction was initiated by the following command:
      Run `dnf5 offline reboot` to reboot and perform the offline transaction.
      """
Given I successfully execute dnf with args "offline-distrosync reboot"
 When I execute dnf with args "offline _execute"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                               |
      | upgrade       | labirinto-2.0-1.fc29.x86_64           |


Scenario: Test offline-upgrade
Given I use repository "simple-base"
  And I execute dnf with args "install labirinto"
  And I use repository "simple-updates"
 When I execute dnf with args "offline-upgrade download"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                               |
      | upgrade       | labirinto-2.0-1.fc29.x86_64           |
  And stderr contains lines
      """
      Transaction stored to be performed offline. Run `dnf5 offline reboot` to reboot and run the transaction. To cancel the transaction and delete the downloaded files, use `dnf5 offline clean`.
      """
 When I execute dnf with args "offline-upgrade status"
 Then the exit code is 0
  And stdout contains lines
      """
      An offline transaction was initiated by the following command:
      Run `dnf5 offline reboot` to reboot and perform the offline transaction.
      """
Given I successfully execute dnf with args "offline-upgrade reboot"
 When I execute dnf with args "offline _execute"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                               |
      | upgrade       | labirinto-2.0-1.fc29.x86_64           |


Scenario: Test offline install with local rpm (absolute path)
Given I use repository "simple-base"
  And I copy file "{context.dnf.fixturesdir}/repos/simple-base/x86_64/labirinto-1.0-1.fc29.x86_64.rpm" to "/tmp/labirinto-1.0-1.fc29.x86_64.rpm"
 When I execute dnf with args "install --offline {context.dnf.installroot}/tmp/labirinto-1.0-1.fc29.x86_64.rpm"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |
 When I execute dnf with args "offline reboot"
  And I execute dnf with args "offline _execute"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


Scenario: Test offline install with local rpm (relative path)
Given I use repository "simple-base"
  And I copy file "{context.dnf.fixturesdir}/repos/simple-base/x86_64/labirinto-1.0-1.fc29.x86_64.rpm" to "/tmp/labirinto-1.0-1.fc29.x86_64.rpm"
  And I set working directory to "{context.dnf.installroot}/tmp/"
 When I execute dnf with args "install --offline ./labirinto-1.0-1.fc29.x86_64.rpm"
 Then the exit code is 0
  And DNF Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |
 When I execute dnf with args "offline reboot"
  And I execute dnf with args "offline _execute"
 Then the exit code is 0
  And Transaction is following
      | Action        | Package                       |
      | install       | labirinto-0:1.0-1.fc29.x86_64 |


# https://github.com/rpm-software-management/dnf5/issues/1851
Scenario: After an offline transaction, installed packages have correct from_repo
Given I successfully execute dnf with args "install --offline flac"
  And I successfully execute dnf with args "offline reboot"
  And I successfully execute dnf with args "offline _execute"
 When I execute dnf with args "repoquery --installed --queryformat="%{{full_nevra}} %{{from_repo}}\n" flac"
 Then the exit code is 0
  And stdout is
      """
      flac-0:1.3.2-8.fc29.x86_64 dnf-ci-fedora
      """
