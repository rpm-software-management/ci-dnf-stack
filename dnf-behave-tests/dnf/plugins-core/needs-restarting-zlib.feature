@bz2092033
Feature: Notify zlib reboot

Background:
    Given I enable plugin "needs_restarting"
      And I use repository "needs-restarting-zlib"
      And I move the clock backward to "before boot-up"
      And I execute dnf with args "install zlib dbus"
      And I move the clock forward to "2 hours"
      And I use repository "needs-restarting-zlib-updates"


Scenario: Update zlib when dbus is installed
    Given I execute dnf with args "upgrade zlib"
     When I execute dnf with args "needs-restarting -r"
     Then the exit code is 1
      And stdout is
          """
          Core libraries or services have been updated since boot-up:
            * zlib (dependency of dbus. Recommending reboot of dbus)

          Reboot is required to fully utilize these updates.
          More information: https://access.redhat.com/solutions/27943
          """

Scenario: Update zlib when dbus is not installed
    Given I execute dnf with args "upgrade zlib"
      And I execute dnf with args "remove dbus"
     When I execute dnf with args "needs-restarting -r"
     Then the exit code is 0
      And stdout is
          """
          No core libraries or services have been updated since boot-up.
          Reboot should not be necessary.
          """
