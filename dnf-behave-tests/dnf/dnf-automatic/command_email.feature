# dnf-automatic disabled by https://github.com/rpm-software-management/dnf/pull/2129
@not.with_os=fedora__ge__41
# dnf-automatic does not have --installroot option.
@no_installroot
Feature: dnf-automatic command_email emitter

Background:
Given I use repository "simple-base"
  And I successfully execute dnf with args "install labirinto"
  And I use repository "simple-updates"


@gh-dnf-2241
Scenario: dnf-automatic pass multiple recipients as separate arguments
  Given I create file "/etc/dnf/automatic.conf" with
    """
    [commands]
    apply_updates = no
    reboot = never
    [emitters]
    emit_via = command_email
    [command_email]
    email_to = recipient1,recipient2
    command_format = "printf '%s\n' {email_to}"
    """
   When I execute dnf-automatic with args "/etc/dnf/automatic.conf"
   Then the exit code is 0
    And stdout contains lines:
    """
    recipient1
    recipient2
    """

