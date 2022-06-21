@bz2092033
Feature: Reboot hint when a package changes files used by another package that needs restarting

Background:
    Given I enable plugin "needs_restarting"
      And I use repository "needs-restarting-dependent-package"
      And I move the clock backward to "before boot-up"
      And I execute dnf with args "install foo bar"
      And I move the clock forward to "2 hours"

Scenario: Updating bar causes a file change used by a package that needs restarting
    Given I execute "/usr/bin/python3 {context.dnf.installroot}/needs-restarting-utils/run-forever.py"
      And I execute dnf with args "reinstall bar"
     When I execute dnf with args "needs-restarting -r"
     Then the exit code is 1
      And stdout is
      """
      Core libraries or services have been updated since boot-up:
        * foo

      Reboot is required to fully utilize these updates.
      More information: https://access.redhat.com/solutions/27943
      """
