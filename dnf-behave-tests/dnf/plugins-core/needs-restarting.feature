@bz1639468
Feature: Reboot hint

Background:
    Given I enable plugin "needs_restarting"
      And I use repository "dnf-ci-fedora"
      And I move the clock backward to "before boot-up"
      And I execute dnf with args "install lame kernel basesystem glibc wget"
      And I move the clock forward to "2 hours"
      And I use repository "dnf-ci-fedora-updates"

@bz1913962
Scenario: Update core packages
    Given I execute dnf with args "upgrade kernel basesystem"
      And I execute dnf with args "upgrade glibc"
      And I execute dnf with args "upgrade lame wget"
     When I execute dnf with args "needs-restarting -r"
     Then the exit code is 1
      And stdout is
          """
          Core libraries or services have been updated since boot-up:
            * glibc
            * kernel
            * kernel-core

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
