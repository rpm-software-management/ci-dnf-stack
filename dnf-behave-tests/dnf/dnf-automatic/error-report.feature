@not.with_os=fedora__ge__41
# dnf-automatic disabled by https://github.com/rpm-software-management/dnf/pull/2129
@no_installroot
Feature: dnf-automatic reports an error when transaction failed


# We are not running in installroot with dnf-automatic,
# so we need to prepare a clean environment.
Background:
Given I delete file "/etc/yum.repos.d/*.repo" with globs
  And I create file "/etc/dnf/dnf.conf" with
    """
    [main]
    plugins=0
    """


# First, install the "test-1.0" package, which should proceed successfully.
# Then, attempt to update to "test-1.1", which contains a broken scriptlet.
# An error should be reported during the installation of the update.
@bz2170093
Scenario: dnf-automatic reports an error when package installation failed
  Given I use repository "dnf-ci-automatic-update"
    And I successfully execute dnf with args "install test-1.0"
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 1
    And Transaction is empty
    And stderr is
    """
    Error in PREIN scriptlet in rpm package test
    Error: Transaction failed
    """


# dnf-automatic disabled by https://github.com/rpm-software-management/dnf/pull/2129
@not.with_os=fedora__ge__41
# https://github.com/rpm-software-management/dnf/issues/1918
# https://issues.redhat.com/browse/RHEL-61882
Scenario: emitters can report errors if configured by send_error_messages = yes
  Given I use repository "dnf-ci-automatic-update"
    And I create file "/etc/dnf/automatic.conf" with
    """
    [commands]
    download_updates = yes
    apply_updates = yes

    [emitters]
    send_error_messages = yes
    emit_via = command_email

    [command_email]
    command_format = "echo {body} > /tmp/dnf_error"
    """
    And I successfully execute dnf with args "install test-1.0"
    And file "/tmp/dnf_error" does not exist
   When I execute dnf-automatic with args "--installupdates"
   Then the exit code is 1
    And Transaction is empty
    And file "/tmp/dnf_error" matches line by line
    """
    An error has occured on: .*
    Error: Transaction failed
    """
