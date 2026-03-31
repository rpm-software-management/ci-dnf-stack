# We modify /etc/rpm/macros.verify on the host
@destructive
@bz1639468
Feature: Reboot hint

Background:
    Given I enable plugin "needs_restarting"
    # We cannot use signed packages because we are moving the clock around,
    # rpm fails to read packages signed in the future.
    Given I use repository "unsigned" with configuration
        | key      | value |
        | gpgcheck | 0     |
    And I create and substitute file "//etc/rpm/macros.verify" with
        """
        %_pkgverify_level digest
        """
      And I move the clock backward to "before boot-up"
      And I successfully execute dnf with args "install kernel-1.0 glibc-1.0"
      And I move the clock forward to "2 hours"

@bz1913962
Scenario: Update core packages
    Given I successfully execute dnf with args "upgrade kernel"
      And I successfully execute dnf with args "upgrade glibc"
     When I execute dnf with args "needs-restarting -r"
     Then the exit code is 1
      And stdout is
          """
          Core libraries or services have been updated since boot-up:
            * glibc
            * kernel

          Reboot is required to fully utilize these updates.
          More information: https://access.redhat.com/solutions/27943
          """


Scenario: Update non-core packages only
    Given I execute dnf with args "upgrade lame basesystem wget"
     When I execute dnf with args "needs-restarting -r"
     Then the exit code is 0
      And stdout is
          """
          No core libraries or services have been updated since boot-up.
          Reboot should not be necessary.
          """


Scenario: Long option form
     When I execute dnf with args "needs-restarting --reboothint"
     Then the exit code is 0
