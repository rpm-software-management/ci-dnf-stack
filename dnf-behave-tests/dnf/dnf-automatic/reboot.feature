@not.with_os=fedora__ge__41
# dnf-automatic disabled by https://github.com/rpm-software-management/dnf/pull/2129
@no_installroot
Feature: dnf-automatic reboots


Background:
Given I delete file "/etc/yum.repos.d/*.repo" with globs
  And I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    plugins=0
    """
  And I use repository "simple-base"
  And I successfully execute dnf with args "install labirinto"
  And I use repository "simple-updates"

Scenario: dnf-automatic does not reboot when reboot = never
  Given I create file "/etc/dnf/automatic.conf" with
    """
    [commands]
    reboot = never
    reboot_command = "echo 'I LOVE REBOOTING'"

    [emitters]
    emit_via = stdio
    """
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | labirinto-0:2.0-1.fc29.x86_64         |
    And stdout does not contain lines:
      """
      I LOVE REBOOTING
      """

Scenario: dnf-automatic reboots when packages changed and reboot = when-changed
  Given I create file "/etc/dnf/automatic.conf" with
    """
    [commands]
    reboot = when-changed
    reboot_command = "echo 'I LOVE REBOOTING'"

    [emitters]
    emit_via = stdio
    """
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | labirinto-0:2.0-1.fc29.x86_64         |
    And stdout contains lines:
      """
      I LOVE REBOOTING
      """

Scenario: dnf-automatic reboots when reboot = when-needed and important package changed
  Given I create file "/etc/dnf/automatic.conf" with
    """
    [commands]
    reboot = when-needed
    reboot_command = "echo 'I LOVE REBOOTING'"

    [emitters]
    emit_via = stdio
    """
    And I use repository "dnf-ci-fedora"
    And I successfully execute dnf with args "install kernel"
    And I use repository "dnf-ci-fedora-updates"
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 0
    And stdout contains lines:
      """
      I LOVE REBOOTING
      """

Scenario: dnf-automatic does not reboot when reboot = when-needed and nothing important changed
  Given I create file "/etc/dnf/automatic.conf" with
    """
    [commands]
    reboot = when-needed
    reboot_command = "echo 'I LOVE REBOOTING'"

    [emitters]
    emit_via = stdio
    """
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 0
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | labirinto-0:2.0-1.fc29.x86_64         |
    And stdout does not contain lines:
      """
      I LOVE REBOOTING
      """

Scenario: dnf-automatic shows error message when reboot command failed
  Given I create file "/etc/dnf/automatic.conf" with
    """
    [commands]
    reboot = when-changed
    reboot_command = "false"

    [emitters]
    emit_via = stdio
    """
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 1
    And Transaction is following
        | Action        | Package                               |
        | upgrade       | labirinto-0:2.0-1.fc29.x86_64         |
    And stderr contains lines:
      """
      Error: reboot command returned nonzero exit code: 1
      """
